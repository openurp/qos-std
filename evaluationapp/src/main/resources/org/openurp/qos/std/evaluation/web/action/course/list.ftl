[#ftl]
[@b.head/]
<div class="grid">
    [@b.messages slash="4"/]
    [@b.form name="evaluateForm" action="!loadQuestionnaire" target="contentDiv"]
    <table class="gridtable"  style="border:0.5px solid #006CB2">
        <thead class="gridhead">
            <tr>
                <th width="5%">课程序号</th>
                <th width="10%">课程代码</th>
                <th width="30%">课程名称</th>
                <th width="18%">开课院系</th>
                <th width="12%">课程类别</th>
                <th width="10%">教师姓名</th>
                <th width="5%">是否评教</th>
                <th width="10%">操作方式</th>
            </tr>
        </thead>
        [#if questionnaireClazzs??]
        <tbody>
        [#list questionnaireClazzs?sort_by(["clazz","crn"]) as questionnaireClazz]
        [#if questionnaireClazz_index % 2 == 0]
            [#assign clazzClass="griddata-even"/]
        [#else]
            [#assign clazzClass="griddata-odd"/]
        [/#if]
        [#if questionnaireClazz.evaluateByTeacher]
            [#list questionnaireClazz.clazz.teachers?if_exists as teacher]
            [#if "1" == evaluateMap[questionnaireClazz.clazz.id?string + "_" + teacher.id?string]?default("0")]
                [#assign flag = true/]
            [#else]
                [#assign flag = false]
            [/#if]
            <tr class="${clazzClass!}">
                <td>${(questionnaireClazz.clazz.crn)!}</td>
                <td>${(questionnaireClazz.clazz.course.code)!}</td>
                <td>${(questionnaireClazz.clazz.course.name)!}</td>
                <td>${(questionnaireClazz.clazz.teachDepart.name)!}</td>
                <td>${(questionnaireClazz.clazz.courseType.name)!}</td>
                <td>${(teacher.user.name)!}</td>
                <td>[#if flag]已评教[#else]未评教[/#if]</td>
                <td>
                    <a href="javascript:doEvaluate('${flag?string("update","evaluate")}','${(questionnaireClazz.clazz.id)!},${(teacher.id)!}')">
                    [#if flag]修改结果[#else]进行评估[/#if]
                    </a>
                </td>
            </tr>
            [/#list]
        [#else]
            [#assign flag=true]
            [#list questionnaireClazz.clazz.teachers as t]
              [#if !(evaluateMap[questionnaireClazz.clazz.id?string + "_"+ t.id])??]
                [#assign flag=false]
              [/#if]
            [/#list]
            <tr class="${clazzClass!}">
                <td>${(questionnaireClazz.clazz.crn)!}</td>
                <td>${(questionnaireClazz.clazz.course.code)!}</td>
                <td>${(questionnaireClazz.clazz.course.name)!}</td>
                <td>${(questionnaireClazz.clazz.teachDepart.name)!}</td>
                <td>${(questionnaireClazz.clazz.courseType.name)!}</td>
                <td>
                [#list (questionnaireClazz.clazz.teachers)?if_exists as teacher]
                    ${(teacher.user.name)!}[#if teacher_has_next],[/#if]
                [/#list]
                </td>
                <td>[#if flag]已评教[#else]未评教[/#if]</td>
                <td>
                    <a href="javascript:doEvaluate('${flag?string("update","evaluate")}','${(questionnaireClazz.clazz.id)!}')">
                    [#if flag]修改结果[#else]进行评估[/#if]
                    </a>
                </td>
            </tr>
        [/#if]
        [/#list]
        </tbody>
        [/#if]
    </table>
    [/@]
    [#if !questionnaireClazzs??]
    <div class="gridempty" style="height: 112px;">
        <div style="padding-top: 40px;">没有查询结果</div>
    </div>
    [/#if]
</div>
<script type="text/javascript">
    function doEvaluate(value, id){
        var evaluateForm = document.evaluateForm;
        bg.form.addInput(evaluateForm, "semester.id", $("input[name='semester.id']").val());
        bg.form.addInput(evaluateForm, "evaluateState", value);
        bg.form.addInput(evaluateForm, "clazzId" ,id);
        bg.form.submit(evaluateForm);
    }
</script>
[@b.foot/]
