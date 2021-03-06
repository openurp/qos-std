/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.qos.std.evaluation.web.action

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.Teacher
import org.openurp.base.model.Semester
import org.openurp.base.std.model.Student
import org.openurp.edu.clazz.model.{Clazz, CourseTaker}
import org.openurp.qos.evaluation.app.course.service.StdEvaluateSwitchService
import org.openurp.qos.evaluation.clazz.model.{EvaluateResult, QuestionResult, QuestionnaireClazz}
import org.openurp.qos.evaluation.config.{Option, Question}
import org.openurp.starter.edu.helper.ProjectSupport

import java.time.{Instant, LocalDate}

class CourseAction extends RestfulAction[EvaluateResult] with ProjectSupport {

  var evaluateSwitchService: StdEvaluateSwitchService = _

  override def search(): View = {
    val std = getUser(classOf[Student])
    val semesterQuery = OqlBuilder.from(classOf[Semester], "semester").where(":now between semester.beginOn and semester.endOn", LocalDate.now)
    val semesterId = getInt("semester.id").getOrElse(entityDao.search(semesterQuery).head.id)
    val semester = entityDao.get(classOf[Semester], semesterId)
    val clazzList = getStdClazzs(std, semester)
    // ??????(????????????,????????????,??????????????????)
    var myClazzs: Seq[QuestionnaireClazz] = Seq()
    if (!clazzList.isEmpty) {
      val query = OqlBuilder.from(classOf[QuestionnaireClazz], "questionnaireClazz")
      query.where("questionnaireClazz.clazz in (:clazzList)", clazzList)
      val myquestionnaires = entityDao.search(query)
      myClazzs = myquestionnaires
    }
    // ??????(????????????,????????????)
    val evaluateMap = getClazzIdAndTeacherIdOfResult(std, semester)
    put("evaluateMap", evaluateMap)
    put("questionnaireClazzs", myClazzs)
    forward()
  }

  def getClazzIdAndTeacherIdOfResult(student: Student, semester: Semester): collection.Map[String, String] = {
    val query = OqlBuilder.from(classOf[EvaluateResult], "evaluateResult")
    query.where("evaluateResult.student = :student ", student)
    query.where("evaluateResult.clazz.semester = :semester", semester)
    val a = entityDao.search(query)
    a.map(obj => (obj.clazz.id.toString + "_" + (if (null == obj.teacher) "0" else obj.teacher.id.toString), "1")).toMap
  }

  def getStdClazzs(student: Student, semester: Semester): Seq[Clazz] = {
    val query = OqlBuilder.from[Clazz](classOf[CourseTaker].getName, "courseTaker")
    query.select("courseTaker.clazz")
    query.where("courseTaker.std=:std", student)
    query.where("courseTaker.semester =:semester", semester)
    entityDao.search(query)
  }

  /**
   * ??????(????????????)
   */
  def loadQuestionnaire(): View = {
    val clazzId = get("clazzId").get
    val evaluateState = get("evaluateState").get
    val semesterId = getInt("semester.id").get
    val ids = get("clazzId").get.split(",")
    // ??????(????????????)
    val clazz = entityDao.get(classOf[Clazz], ids(0).toLong)
    if (null == clazz) {
      addMessage("??????????????????!")
      return forward("errors")
    }
    val evaluateSwitchs = evaluateSwitchService.getEvaluateSwitch(clazz.semester, clazz.project)
    if (evaluateSwitchs.isEmpty) {
      addMessage("?????????????????????????????????!")
      return forward("errors")
    }
    val evaluateSwitch = evaluateSwitchs.head
    if (!evaluateSwitch.isOpenedAt(Instant.now)) {
      addMessage("?????????????????????????????????,??????????????????!" + evaluateSwitch.beginAt + "???" + evaluateSwitch.endAt)
      return forward("errors")
    }
    // ??????(????????????,??????????????????)
    val questionnaireClazzs = entityDao.findBy(classOf[QuestionnaireClazz], "clazz.id", List(clazz.id))
    if (questionnaireClazzs.isEmpty) {
      addMessage("??????????????????!")
      return forward("errors")
    }

    val questionnaireClazz = questionnaireClazzs.head
    var questions = questionnaireClazz.questionnaire.questions
    questions.sortWith((x, y) => x.priority < y.priority)

    // ??????(????????????,????????????????????????)
    val teachers = Collections.newBuffer[Teacher]
    if (questionnaireClazz.evaluateByTeacher) {
      val teacher = entityDao.get(classOf[Teacher], ids(1).toLong)
      teachers += teacher
    } else {
      teachers ++= clazz.teachers
    }

    // ??????(????????????)
    if ("update".equals(evaluateState)) {
      var teacherId: Long = 0
      if (questionnaireClazz.evaluateByTeacher) {
        teacherId = ids(1).toLong
      } else {
        teacherId = teachers.head.id
      }
      val std = getUser(classOf[Student])
      val evaluateResult = getResultByStdIdAndClazzId(std.id, clazz.id, teacherId)
      if (null == evaluateResult) {
        addMessage("error.dataRealm.insufficient")
        forward("errors")
      }
      // ??????(????????????)
      val questionMap = evaluateResult.questionResults.map(q => (q.question.id.toString, q.option.id)).toMap
      put("questionMap", questionMap)
      put("evaluateResult", evaluateResult)
    }

    put("clazz", clazz)
    put("teachers", teachers)
    put("questions", questions)
    //questionnaire = entityDao.get(classOf[Questionnaire], questionnaireClazz.questionnaire.id)
    put("questionnaire", questionnaireClazz.questionnaire)
    put("evaluateState", evaluateState)
    forward()
  }

  def getResultByStdIdAndClazzId(stdId: Long, clazzId: Long, teacherId: Long): EvaluateResult = {
    val query = OqlBuilder.from(classOf[EvaluateResult], "evaluateResult")
    query.where("evaluateResult.student.id =:stdId", stdId)
    query.where("evaluateResult.clazz.id =:clazzId", clazzId)
    if (0 != teacherId) {
      query.where("evaluateResult.teacher.id =:teacherId", teacherId)
    } else {
      query.where("evaluateResult.teacher is null")
    }
    val result = entityDao.search(query)

    if (result.size > 0) result.head else null.asInstanceOf[EvaluateResult]
  }

  override def save(): View = {
    val std = getUser(classOf[Student])
    val clazzId = getLong("clazz.id").get
    val teacherId = getLong("teacherId").get
    val teacherIds = longIds("teacher")
    // ??????????????????,??????????????????
    val query = OqlBuilder.from(classOf[QuestionnaireClazz], "questionnaireClazz")
    query.where("questionnaireClazz.clazz.id =:clazzId", clazzId)
    val questionnaireClazzs = entityDao.search(query)
    if (questionnaireClazzs.isEmpty) {
      addMessage("field.evaluate.questionnaire")
      forward("errors")
    }
    val questionnaireClazz = questionnaireClazzs.head
    // ??????(????????????)
    var evaluateResults: Seq[EvaluateResult] = Seq()
    val queryResult = OqlBuilder.from(classOf[EvaluateResult], "evaluateResult")
    queryResult.where("evaluateResult.clazz.id =:clazzId", clazzId)
    //    queryResult.where("evaluateResult.clazz.semester.id =:semesterId",semesterId)
    queryResult.where("evaluateResult.student =:std", std)
    // ??????????????????
    if (teacherIds.size == 0) {
      evaluateResults = entityDao.search(queryResult)
    } else if (teacherIds.size == 1) {
      queryResult.where("evaluateResult.teacher.id =:teacherId", teacherId)
      evaluateResults = entityDao.search(queryResult)
    } //    ???????????????????????????????????????
    else if (teacherIds.size > 1) {
      queryResult.where("evaluateResult.teacher.id in(:teacherIds)", teacherIds)
      evaluateResults = entityDao.search(queryResult)
    }

    var clazz: Clazz = null
    var teacher: Teacher = null
    val newTeacherIds = Collections.newBuffer[Long]
    try {
      // ??????????????????
      if (evaluateResults.nonEmpty) {
        evaluateResults foreach { evaluateResult =>
          clazz = evaluateResult.clazz
          teacher = evaluateResult.teacher
          newTeacherIds += teacher.id
          // ??????(????????????)
          val questionResults = evaluateResult.questionResults
          val questions = questionnaireClazz.questionnaire.questions
          // ??????(??????????????????)
          val oldQuestions = Collections.newBuffer[Question]
          questionResults foreach { questionResult =>
            oldQuestions += questionResult.question
          }
          questions foreach { question =>
            if (!oldQuestions.contains(question)) {
              val optionId = getLong("select" + question.id).get
              val option = entityDao.get(classOf[Option], optionId)
              val questionResult = new QuestionResult()
              questionResult.indicator = question.indicator
              questionResult.question = question
              questionResult.option = option
              questionResult.result = evaluateResult
              evaluateResult.questionResults += questionResult
            }
          }
          // ????????????
          //          evaluateResult.remark = get("evaluateResult.remark").getOrElse("")
          // ??????
          questionResults foreach { questionResult =>
            val question = questionResult.question
            val optionId = getLong("select" + question.id).get
            if (optionId == 0L) {
              questionResult.result = null
              entityDao.remove(questionResult)
            }
            if (!questionResult.option.id.equals(optionId)) {
              val option = entityDao.get(classOf[Option], optionId)
              questionResult.option = option
              questionResult.score = question.score * option.proportion.floatValue()
            }
          }
          entityDao.saveOrUpdate(questionResults)
        }
        var newId: Long = 0L
        //       ???????????????????????????????????????????????????????????????
        if (teacherIds.size > newTeacherIds.size) {
          teacherIds foreach { id =>
            if (!newTeacherIds.contains(id)) {
              newId = id
            }
          }
          val evaluateResult = new EvaluateResult()
          evaluateResult.clazz = clazz
          evaluateResult.department = clazz.teachDepart
          evaluateResult.student = std
          evaluateResult.statType = 1
          evaluateResult.teacher = entityDao.get(classOf[Teacher], newId)
          evaluateResult.updatedAt = Instant.now
          questionnaireClazz.questionnaire.questions foreach { question =>
            val optionId = getLong("select" + question.id).get
            val option = entityDao.get(classOf[Option], optionId)
            val questionResult = new QuestionResult()
            questionResult.question = question
            questionResult.indicator = question.indicator
            questionResult.result = evaluateResult
            questionResult.option = option
            questionResult.score = question.score * option.proportion.floatValue()
            evaluateResult.questionnaire = questionnaireClazz.questionnaire
            evaluateResult.questionResults += questionResult
          }
          //          evaluateResult.remark = get("evaluateResult.remark").getOrElse("")
          entityDao.saveOrUpdate(evaluateResult)
        }
      } //      ??????????????????
      else {
        clazz = entityDao.get(classOf[Clazz], clazzId)
        val teachers = entityDao.find(classOf[Teacher], teacherIds)

        // ??????(??????)
        val questionnaire = questionnaireClazz.questionnaire
        if (questionnaire == null || questionnaire.questions == null) {
          addMessage("??????????????????!")
          forward("errors")
        }

        //  ????????????
        if (teachers.size == 1) {
          teacher = teachers.head
          var evaluateTeacher = teacher
          val evaluateResult = new EvaluateResult()
          evaluateResult.clazz = clazz
          evaluateResult.department = clazz.teachDepart
          evaluateResult.student = std
          evaluateResult.teacher = evaluateTeacher
          evaluateResult.statType = 1
          evaluateResult.updatedAt = Instant.now
          questionnaire.questions foreach { question =>
            val optionId = getLong("select" + question.id).get
            val option = entityDao.get(classOf[Option], optionId)
            val questionResult = new QuestionResult()
            questionResult.question = question
            questionResult.indicator = question.indicator
            questionResult.result = evaluateResult
            questionResult.option = option
            questionResult.score = question.score * option.proportion.floatValue()
            evaluateResult.questionnaire = questionnaire
            evaluateResult.questionResults += questionResult
          }
          //          evaluateResult.remark = get("evaluateResult.remark").getOrElse("")
          evaluateResult.score = evaluateResult.questionResults.foldLeft(0f)(_ + _.score)
          entityDao.saveOrUpdate(evaluateResult)
        }
        //        ????????????????????????????????????????????????
        if (teachers.size > 1 & (!questionnaireClazz.evaluateByTeacher)) {
          teachers foreach { teacher =>
            val evaluateResult = new EvaluateResult()
            evaluateResult.clazz = clazz
            evaluateResult.statType = 1
            evaluateResult.department = clazz.teachDepart
            evaluateResult.student = std
            evaluateResult.teacher = teacher
            evaluateResult.updatedAt = Instant.now
            questionnaire.questions foreach { question =>
              val optionId = getLong("select" + question.id).get
              val option = entityDao.get(classOf[Option], optionId)
              val questionResult = new QuestionResult()
              questionResult.question = question
              questionResult.indicator = question.indicator
              questionResult.result = evaluateResult
              questionResult.option = option
              questionResult.score = question.score * option.proportion.floatValue()
              evaluateResult.questionnaire = questionnaire
              evaluateResult.questionResults += questionResult
            }
            evaluateResult.score = evaluateResult.questionResults.foldLeft(0f)(_ + _.score)
            //            evaluateResult.remark = get("evaluateResult.remark").getOrElse("")
            entityDao.saveOrUpdate(evaluateResult)
          }
        }
      }
      redirect("search", "&semester.id=" + clazz.semester.id, "info.save.success")
    } catch {
      case e: Exception =>
        e.printStackTrace()
        redirect("search", "&semester.id=" + clazz.semester.id, "info.save.failure")
    }
  }

  override protected def indexSetting(): Unit = {
    val std = getUser(classOf[Student])
    put("project", std.project)
    val semester = getInt("semester.id") match {
      case Some(semesterId) => entityDao.get(classOf[Semester], semesterId)
      case None => this.getCurrentSemester
    }
    put("currentSemester", semester)
  }

}
