[#ftl]
[@b.head/]
[#if "update" == evaluateState]
    [#assign state = "修改"/]
[#else]
    [#assign state = "添加"/]
[/#if]
[@b.toolbar title='${state}文字评估' id='textEvaluateStudentEditBar']
    bar.addBack();
[/@]
[@b.form name="evaluateEditForm" title="文字评估" action="!saveTextEvaluate" theme="list"]
    <li>
        <label class="title">课程名称:</label>${(clazz.course.name)!}
    </li>
    <li>
        <label class="title">教师姓名:</label>${(teacher.user.name)!}
        <input type="hidden" name="teacherId" value="${(teacher.id)!}"/>
    </li>
    [@b.select label="评价对象:" name="evaluateByTeacher" items={'1':'教师','0':'课程'} value=((textEvaluation.evaluateByTeacher)?string("1","0"))! required="true" /]
    [@b.textarea label="授课意见(200字)" check="maxLength(200)" id="textOpinion" name="textOpinion" value="" style="width:85%" required="true" /]
    [#if textEvaluations??]
        [@b.field label="历史意见"]
        <table class="infoTable" style="width:80%;">
            [#list textEvaluations?if_exists as e]
            <tr><td>${(e.content?html)!} ${e.evaluateAt?string('yyyy-MM-dd HH:mm')}</td></tr>
            [/#list]
        </table>
    [/@]
    [/#if]
    [@b.formfoot]
        <input type="hidden" name="semester.id" id="semesterId" value=""/>
        <input type="hidden" name="clazz.id" value="${(clazz.id)!}">
        [@b.reset/]
        <input type="button" id="btnWait" value="数据提交中,请等待..." onClick="alertWait()" style="display:none" />
        [@b.submit id="btnSave" value="${b.text('action.save')}" onsubmit="doPost()" /]
    [/@]
[/@]
<script type="text/javaScript">
    function doPost(){
        if (!confirm("确认提交?")){
            return false;
        }
        if ($.trim($("#textOpinion").val()) == ""){
            alert("你的意见还没有填写!");
            return false;
        }
        if ($("#textOpinion").val().length > 200){
            alert("你的意见部分字数过多,请缩减后提交!");
            return false;
        }
        return true;
        $("#semesterId").val($("input[name='semester.id']").val());
        $("#btnSave").hide();
        $("#btnReset").hide();
        $("#btnWait").show();
    }
    function alertWait(){
        alert("数据提交中,请耐心等待...");
    }
</script>

[#--
<#include "/template/head.ftl"/>
<script language="JavaScript" type="text/JavaScript" src="scripts/validator.js"></script>
<BODY LEFTMARGIN="0" TOPMARGIN="0">
<table id="backBar"></table>
<script>
   var bar = new ToolBar('backBar','<#if "update"==Parameters['evaluateState']><@text name="evaluate.updateTitle"/><#else><@text name="evaluate.doTitle"/></#if>',null,true,true);
   bar.setMessage('<@getMessage/>');
   bar.addBack('<@text name="action.back"/>');
</script>
    <table id="tableName" align="center" class="listTable" width="100%">
        <form name="textEvaluate" method="post" action="" >
        <tr>
            <td align="center" class="grayStyle" id="f_teacher" width="10%">
                <@text name="field.select.evaluateRemark"/><font color="red">*<font>
            </td>
            <td colspan="2" align="left" class="brightStyle" width="90%">
                <@text name="attr.courseName"/>：<font color="blue"><@i18nName (teachTask.course)?if_exists/></font>
                <br>
                <@text name="course.teacher"/>：<@i18nName (teacher)?if_exists/>
                <input type="hidden" name="teacherId" value="${teacher.id}"/>
            </td>
        </tr>
        <tr>
            <td align="center" class="brightStyle" id="f_textOpinion" width="10%">
                授课意见<br>(200字以内)
            </td>
            <td align="left" class="brightStyle" width="90%">
                <textarea name="textOpinion" cols="80" rows="4"></textarea>
            </td>
        </tr>
        <tr>
            <td align="center" class="grayStyle" width="10%">历史意见</td>
            <td align="left" class="grayStyle" width="90%">
                <#if textEvaluationList?exists>
                    <#list textEvaluationList as textEvaluation>
                         <li>${textEvaluation.context?html}</li>
                    </#list>
                </#if>
            </td>
        </tr>
        <tr>
            <td colspan="2" align="center" class="darkColumn">
                <input type="hidden" name="taskId" value="${teachTask.id}">
                <input type="hidden" name="semesterId" value="${Parameters['semester.id']}"/>
                <button id="updateButton"  name="evaluateQuestionnaire" onClick="doAction(document.textEvaluate)"><@text name="system.button.submit"/></button>
            </td>
        </tr>
        </form>
    </table>
</body>
<script language="javascript">
    function doAction(form){
         if(confirm("你确定要现在提交文字评教意见吗?")){
            if(form['textOpinion'].value==""){
                   alert("你的意见还没有填!");
                return;
            }
            if(form['textOpinion'].value.length>200){
               alert("你的意见字数过多,请缩减后提交.");
               return;
            }
            var buttonUpdate = document.getElementById("updateButton");
            form.action="textEvaluateStudent!saveTextEvaluate.action";
            form.submit();
             buttonUpdate.innerHTML="数据提交中,请耐心等待....";
             buttonUpdate.onclick=alertWait;
         }
    }
    function alertWait(){
      alert('数据提交中,请耐心等待....');
    }
</script>
<#include "/template/foot.ftl"/>
--]
