[#ftl]
[@b.head/]
[#if "update" == evaluateState]
    [#assign state = "修改"/]
[#else]
    [#assign state = "添加"/]
[/#if]
[@b.toolbar title='${state}课程评估' id='textEvaluateStudentEditBar']
    bar.addBack();
[/@]
[@b.form name="evaluateEditForm" title="课程评估" action="!save" theme="list"]
    [#if (questionnaire.title)??]
    <pre align="center">
    <b>${(questionnaire.title)!}</b>
    </pre>
    [/#if]
    <li align="right">
    课程名称:${(clazz.course.name)!}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    教师姓名:
        [#list teachers?if_exists as teacher]
        ${(teacher.user.name)!}[#if teacher_has_next],[/#if]
        <input type="hidden" name="teacherId" value="${(teacher.id)!}" />
        [/#list]
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </li>
    [@b.field label="问题信息"]
        <table class="gridtable" style="width:90%" align="center">
            <thead class="gridhead">
                <tr>
                    <th width="10%">问题类别</td>
                    <th width="50%">问题内容</td>
                    <th width="40%">选项</td>
                </tr>
            </thead>
            <tbody id="evaluateTB">
            [#list questions as question]
            [#if question_index % 2 == 0]
                [#assign questionClass = "griddata-even"/]
            [#else]
                [#assign questionClass = "griddata-odd"/]
            [/#if]
                <tr class="${questionClass!}">
                    <td>${(question.questionType.name)!}</td>
                    <td style="text-align:left;padding-left:5px;">${(question_index+1)!}:${(question.content)!}
                   [#-- [#if (question.addition)?exists][#if question.addition]<font color="red">(附加题)</font>[/#if][/#if]--]
                    </td>
                    <td>
                    [#if (question.optionGroup.options)??]
                    [#list (question.optionGroup.options)?sort_by("proportion")?reverse as option]
                        <input type="radio" id="op_${(question.id)}_${option.id}" name="select${(question.id)!}" value="${(option.id)!}"
                        [#if questionMap?? && questionMap[(question.id)?string]?default(0)==(option.id)]checked[/#if]/>
                        <label for="op_${(question.id)}_${option.id}">${(option.name)!}&nbsp;</label>
                    [/#list]
                    [/#if]
                    </td>
                </tr>
            [/#list]
            </tbody>
        </table>
    [/@]
    [@b.field label="文字评教"]
    <table  style="width:90%" align="center">
    <tr>
    <td>
    <textarea style="width:100%" rows="4" maxLength=255  name="evaluateResult.remark" id="evaluateResult.remark" >${(evaluateResult.remark?html)?default('')}</textarea>
    </td>
    </tr>
        </table>
        [/@]
    [@b.formfoot align="center"]
        <input type="hidden" name="semester.id" id="semesterId" value=""/>
        <input type="hidden" name="clazz.id" value="${(clazz.id)!}">
        <input type="hidden" name="teacher.ids" value="[#list teachers?if_exists as teacher]${(teacher.id)!}[#if teacher_has_next],[/#if][/#list]"/>
        [@b.submit id="btnSave" value="${b.text('action.save')}" onsubmit="doPost();" /]
        <input type="button" id="btnWait" value="数据提交中,请等待..." onClick="alertWait()" style="display:none" />
        <input type="reset" id="btnReset" value="重置" />
    [/@]
[/@]
<script type="text/javaScript">
    function mergeCells(){
        var firstTd = null;
        $("#evaluateTB>tr").each(function(i){
            var td = $(this).find("td:eq(0)");
            if (firstTd != null && firstTd.html() == td.html()){
                td.remove();
                firstTd.prop("rowSpan",firstTd.prop("rowSpan")+1);
            } else {
                firstTd = td;
            }
        });
    }

    mergeCells();

    function doPost(){
        var errors = "";
        var num =0;
        var errors2 ="";
        [#list questions?sort_by("priority")?if_exists as question]
            var value = $("input[name='select${(question.id)!}']:checked").val();
            if (undefined == value || 0 == value){
                errors += "${(question_index+1)!},";
            }
            var nums = 0;
            var optionV = "";
            var optionScore = "";
            [#if question.optionGroup??]
            [#list (question.optionGroup.options)?sort_by("proportion") as option]
            nums +=1;
                if(${question.optionGroup.options?size} ==nums){
                    optionV = ${option.id!};
                }
                if(${option.id!} ==value){
                    optionScore = ${option.proportion!};
                }
            [/#list]
            [#else]
            [/#if]
            var op =0;
       [#--
            [#list questionnaire.oppoQs as oppoQ]
            if(${oppoQ.orginQuestion.id!} == ${question.id!}){
                if(${question.optionGroup.oppoVal!} > optionScore){
                errors2 += "${(question_index + 1)!},";
                op+=1;
                }
            [#list questions?sort_by("priority")?reverse?if_exists as question2]
            var value2 = $("input[name='select${(question.id)!}']:checked").val();
                if(${oppoQ.oppoQuestion.id!} == ${question2.id!}){
                    [#list (question.optionGroup.options)?sort_by("proportion")?reverse as option2]
                        if(${option2.id!} ==value2){
                        optionScore = ${option2.proportion!};
                        }
                   [/#list]
                }
                if(${question2.optionGroup.oppoVal!} > optionScore){
                    errors2 += "${(question_index + 1)!},";
                    op+=1;
                }
            [/#list]
            }
            [/#list]
            --]

            if(value == optionV){
            //alert(value+"--"+optionV);
                num +=1;
            }

        [/#list]

        if (errors != ""){
            errors = "你第" + errors.substring(0,errors.lastIndexOf(",")) + "题没有选择答案,请全部选择以后再提交!";
            alert(errors);
            return false;
        }
        if(errors2 !=""){
        errors = errors2;
        errors = "你第" + errors.substring(0,errors.lastIndexOf(",")) + "题所选答案低于倾向权重,请修改答案后再提交!";
            alert(errors);
            return false;
        }

        var str = document.getElementById("evaluateResult.remark").value;

        if(num >0){
            if(str ==""){
                alert("请填写备注信息后提交！");
                return false;
            }
        }
        if(str.length >300){
            alert("备注信息不可超过300字！");
            return false;
        }
        if (!confirm("确认提交?")){
            return false;
        }
        $("#semesterId").val($("input[name='semester.id']").val());
        $("#btnSave").hide();
        $("#btnReset").hide();
        $("#btnWait").show();
        return true;
    }
    function alertWait(){
        alert("数据提交中,请耐心等待...");
    }
</script>
