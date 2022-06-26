[#ftl]
[@b.head/]
<style>
    #tabnav ul{
        height: 24px;
        margin:-20px 0 0 3%;
        padding-left: 10px;
    }
    #tabnav ul li{
        margin: 0;
        padding: 0;
        display: inline;
        list-style-type: none;
        float:left;
    }
    .tab{
        float: left;
        background: #EFF0EA;
        font-size: 12px;
        line-height: 14px;
        font-weight: bold;
        padding: 2px 10px 2px 10px;
        margin-right: 4px;
        border: 1px solid #0065ce;
        text-decoration: none;
        color: #666;
        cursor:pointer;
    }
    #container{
        width: 95%;
        height:auto!important;
        height:500px;
        min-height:500px;
        border: 1px solid #0065ce;
        background: #fff;
        border-top: 0px solid #fff;
        margin:-4px 0 0 0;
    }
    #infoDiv {
        position: absolute;
        width: 70%;
        top:40%;
        left: 50%;
        border:#006CB2 solid 1px;
        background-color: #FFFFFF;
        z-index: 20;
        margin-top:-100px;
        margin-left:-35%;
        font-size:13px;
    }
    #msg{
        word-wrap:break-word;word-break:break-all;
        font-size: 12px;
        overflow:auto;
        background-color: #fff;
        color: #000;
        padding-right:5px;
        padding-left:5px;
        font-family: courier;
        letter-spacing:0;
        line-height:12px;
        border-style:1px gray solid;
        width:100%;
        height:100px;
        padding:0px;
    }
</style>
[@b.toolbar title='评教回复及教师公告查询' id='remsgStudentBar']
    bar.addBack();
[/@]
[@b.form name="sa" action="!search"]
<div style="margin:0;width:95%;height:24px;border-bottom: 1px solid #0065ce;">
    <div id="messageDiv"></div>
</div>
<div id="tabnav">
    <ul>
        <li onClick="switchTbs('myMsgTb');"><div onMouseOver="changeBgColorOver(this);" onMouseOut="changeBgColorOut(this);" id="myMsgTb" class="tab" style="border-bottom: 1px solid #fff;background:#FFF;color:#000;">我的评教回复</div></li>
        <li onClick="switchTbs('otherMsgTb');"><div onMouseOver="changeBgColorOver(this);" onMouseOut="changeBgColorOut(this);" id="otherMsgTb" class="tab">其他的评教回复</div></li>
        <li onClick="switchTbs('annTb');"><div onMouseOver="changeBgColorOver(this);" onMouseOut="changeBgColorOut(this);" id="annTb" class="tab">教师公告</div></li>
    </ul>
</div>

<div id="container">
    <div id="myRemsgTable" >
    <table class="gridtable" style="width:90%;margin-top:15px;" align="center">
        <thead class="gridhead">
            <tr>
                <th colspan="3">
                    我的评教回复
                </td>
            </tr>
            <tr>
                <th>教师姓名</th>
                <th>课程名称</th>
                <th>开课院系</th>
            </tr>
        </thead>
        [#assign k = 0/]
        [#assign z = 0/]
        [#if clazzs??]
        <tbody>
        [#list clazzs as clazz]
            <tr class='${(k % 2 == 0)?string("griddata-odd","griddata-even")}'>
                <td style='padding-left:${(textEvaluationMap.get(clazz[0].id))?exists?string("15","31")}px;text-align:left;'>
                    [#if (textEvaluationMap.get(clazz[0].id))?exists]
                        <a id="myEvaluation${k}" onClick="showElement(this)" style="float:left;cursor:pointer;">+</a>
                    [/#if]
                    ${(clazz[0].user.name)!}
                </td>
                <td>${(clazz[1].course.name)!}</td>
                <td>${(clazz[1].teachDepart.name)!}</td>
            </tr>
            [#if (textEvaluationMap.get(clazz[0].id))?exists]
                [#list textEvaluationMap.get(clazz[0].id)?sort_by("evaluateAt") as textEvaluation]
                    [#assign isAnnCount = 0/]
                    [#list textEvaluation.teacherRemessages as remsgBool]
                        [#if !remsgBool.visible]
                            [#assign isAnnCount = isAnnCount +1/]
                        [/#if]
                    [/#list]
                    [#assign myTextEvaluationFlag = ((textEvaluation.teacherRemessages)?size > 0) && ((textEvaluation.teacherRemessages)?size > isAnnCount)/]
                    <tr class='${(k % 2 == 0)?string("griddata-odd","griddata-even")}' id='myEvaluation${k}SubTr' name='myEvaluation${k}SubTr' style="text-align:left;display:none;">
                        <td colspan="3" [#if myTextEvaluationFlag]style="padding-left:30px;"[#else]style="padding-left:46px;"[/#if]>
                            [#if myTextEvaluationFlag]
                                <a id="myEvaluationText${z}" onClick="showSubElement(this)" style="float:left;cursor:pointer;">+</a>
                            [/#if]
                            您于 ${(textEvaluation.evaluateAt?string("yyyy-MM-dd HH:mm"))!} 评教：<font color="blue"><strong>${(textEvaluation.content)!}</strong></font>
                        </td>
                    </tr>
                    [#if myTextEvaluationFlag]
                        <tr class='${(k % 2 == 0)?string("griddata-odd","griddata-even")}' id='myEvaluationText${z}SubTr' name='myEvaluationText${z}SubTr' style="text-align:left;display:none;">
                            <td colspan="3" style="padding-left:58px;">
                            [#list textEvaluation.teacherRemessages?sort_by("createdAt") as remsg]
                            [#if remsg.visible]
                            <div style="line-height:17px;">
                                  ${remsg.createdAt?string("yyyy-MM-dd HH:mm")} 回复：
                                  <font color="blue">
                                  [#if !(remsg.remessage)?exists || (remsg.remessage?length < 21)]
                                      <a onClick="showMessage('${(remsg.remessage)!}')" title="${(remsg.remessage)!}" style="cursor:pointer;">
                                          ${(remsg.remessage)?default('')}
                                      </a>
                                  [#else]
                                      <a onClick="showMessage('${(remsg.remessage)!}')" title="${(remsg.remessage)?default('')}" style="cursor:pointer;">
                                          ${(remsg.remessage)?default('')[0..20]}...
                                      </a>
                                  [/#if]
                                  </font>
                              </div>
                            [/#if]
                            [/#list]
                            </td>
                        </tr>
                    [/#if]
                    [#assign z = z + 1/]
                [/#list]
            [/#if]
            [#assign k = k + 1/]
        [/#list]
        </tbody>
        [/#if]
    </table>
    </div>

    <div id="otherRemsgTable" style="display:none;">
    <table class="gridtable" style="width:90%;margin-top:15px;" align="center">
        <thead class="gridhead">
            <tr>
                <th colspan="3">
                    其它的评教回复
                </td>
            </tr>
            <tr>
                <th>教师姓名</th>
                <th>课程名称</th>
                <th>开课院系</th>
            </tr>
        </thead>
        [#assign j = 0/]
        [#assign y = 0/]
        [#if clazzs??]
        <tbody>
        [#list clazzs as clazz]
            <tr class='${(j % 2 == 0)?string("griddata-odd","griddata-even")}'>
                <td style='padding-left:${(otherMap.get(clazz[0].id))?exists?string("15","31")}px;text-align:left;'>
                    [#if (otherMap.get(clazz[0].id))?exists]
                        <a id="otherTextEvaluation${j}" onClick="showOtherElement(this,'${j}')" style="float:left;cursor:pointer;">+</a>
                    [/#if]
                    ${(clazz[0].user.name)!}
                </td>
                <td>${(clazz[1].course.name)!}</td>
                <td>${(clazz[1].teachDepart.name)!}</td>
            </tr>
            [#if (otherMap.get(clazz[0].id))?exists]
                [#list otherMap.get(clazz[0].id)?sort_by("textEvaluation")?reverse as remessage]
                    [#if !((remessage_index > 0) && (remessage.textEvaluation.id == tempRemsg.textEvaluation.id))]
                    <tr class='${(j % 2 == 0)?string("griddata-odd","griddata-even")}' id='otherTextEvaluationTr${j}' name='otherTextEvaluation${j}SubTr' style="text-align:left;display:none;">
                        <td colspan="3" style="padding-left:30px;">
                            <a id="otherEvaluation${y}" onClick="showOtherSubElement(this)" style="float:left;cursor:pointer;">+</a>
                            ***于 ${(remessage.textEvaluation.evaluateAt?string("yyyy-MM-dd HH:mm"))!} 评教：<font color="blue"><strong>${(remessage.textEvaluation.content)!}</strong></font>
                        </td>
                    </tr>
                    [#assign y = y + 1/]
                    [/#if]
                    <tr class='${(j % 2 == 0)?string("griddata-odd","griddata-even")}' id='otherTextEvaluationSubTr${j}' name="otherEvaluation${y-1}SubTr" style="text-align:left;display:none;">
                        <td colspan="3" style="padding-left:50px;">
                        <div style="line-height:17px;">
                              ${remessage.createdAt?string("yyyy-MM-dd HH:mm")} 回复：
                              <font color="blue">
                              [#if !(remessage.remessage)?exists || (remessage.remessage?length < 21)]
                                  <a onClick="showMessage('${(remessage.remessage)!}')" title="${(remessage.remessage)!}" style="cursor:pointer;">
                                      ${(remessage.remessage)?default('')}
                                  </a>
                              [#else]
                                  <a onClick="showMessage('${(remessage.remessage)!}')" title="${(remessage.remessage)?default('')}" style="cursor:pointer;">
                                      ${(remessage.remessage)?default('')[0..20]}...
                                  </a>
                              [/#if]
                              </font>
                          </div>
                        </td>
                    </tr>
                    [#assign tempRemsg = remessage/]
                [/#list]
            [/#if]
            [#assign j = j + 1/]
        [/#list]
        </tbody>
        [/#if]
    </table>
    </div>

    <div id="annTable" style="display:none">
    <table class="gridtable" style="width:90%;margin-top:15px;" align="center">
        <thead class="gridhead">
            <tr>
                <th colspan="3">
                    教师公告
                </td>
            </tr>
            <tr>
                <th>教师姓名</th>
                <th>课程名称</th>
                <th>开课院系</th>
            </tr>
        </thead>
        [#assign i = 0/]
        [#if clazzs??]
        <tbody>
        [#list clazzs as clazz]
            <tr class='${(i % 2 == 0)?string("griddata-odd","griddata-even")}'>
                <td style='padding-left:${(annMap.get(clazz[0].id))?exists?string("15","31")}px;text-align:left;'>
                    [#if (annMap.get(clazz[0].id))?exists]
                        <a id="annEvaluationText${i}" onClick="showSubElement(this)" style="float:left;cursor:pointer;">+</a>
                    [/#if]
                    ${(clazz[0].user.name)!}
                </td>
                <td>${(clazz[1].course.name)!}</td>
                <td>${(clazz[1].teachDepart.name)!}</td>
            </tr>
            [#if (annMap.get(clazz[0].id))?exists]
                <tr class='${(i % 2 == 0)?string("griddata-odd","griddata-even")}' id='annEvaluationText${i}SubTr' name='annEvaluationText${i}SubTr' style="text-align:left;display:none;">
                    <td colspan="3" style="padding-left:35px;">
                    [#list annMap.get(clazz[0].id)?sort_by("createdAt") as ann]
                    <div style="line-height:17px;">
                          此公告于 ${ann.createdAt?string("yyyy-MM-dd HH:mm")} 发布：
                          <font color="blue">
                          [#if !(ann.remessage)?exists || (ann.remessage?length < 21)]
                              <a onClick="showMessage('${(ann.remessage)!}')" title="${(ann.remessage)!}" style="cursor:pointer;">
                                  ${(ann.remessage)?default('')}
                              </a>
                          [#else]
                              <a onClick="showMessage('${(ann.remessage)!}')" title="${(ann.remessage)?default('')}" style="cursor:pointer;">
                                  ${(ann.remessage)?default('')[0..20]}...
                              </a>
                          [/#if]
                          </font>
                      </div>
                    [/#list]
                    </td>
                </tr>
            [/#if]
        [/#list]
        </tbody>
        [/#if]
    </table>
    </div>

</div>
[/@]
<div id="infoDiv" style="display:none;">
    [@b.form name="textEvaluationInfoForm" action="!save" theme="list"]
         [@b.textarea label="详细内容" check="maxLength(200)" id="msg" name="msg" readOnly="readOnly" style="width:85%"/]
         [@b.formfoot]
             <input type="button" value="关闭" onClick="hiddenInfo();" class="buttonStyle" id="closeBack" />
        [/@]
    [/@]
</div>
<script type="text/javaScript">
    var currentTag = "myMsgTb";

    function switchTbs(tbId){
        var tbDivs = $("#tabnav>ul>li>div");
        refreshList(tbId);
        tbDivs.each(function(i,obj){
            obj.style.borderBottomColor = "#0065ce";
            obj.style.background = "#EFF0EA";
            obj.style.color = "#666";
        });
        var tb = $("#" + tbId).get(0);
        tb.style.borderBottomColor = "#fff";
        tb.style.background = "#fff";
        tb.style.color = "#000";
        currentTag = tbId;
    }

    function refreshList(listType){
        if(listType == "myMsgTb"){
            $('#annTable').hide();
            $('#otherRemsgTable').hide();
            $('#myRemsgTable').show();
        }else if(listType == "otherMsgTb"){
            $('#annTable').hide();
            $('#otherRemsgTable').show();
            $('#myRemsgTable').hide();
        }else if(listType == "annTb"){
            $('#annTable').show();
            $('#otherRemsgTable').hide();
            $('#myRemsgTable').hide();
        }
    }

    function changeBgColorOver(obj){
        if(obj.id != currentTag){
            obj.style.background = "#c7dbff";
        }
    }
    function changeBgColorOut(obj){
        if(obj.id != currentTag){
            obj.style.background = "#EFF0EA";
        }
    }

    function showElement(obj){
        var a = $(obj);
        var tr = $("tr[name='" + a.prop("id") + "SubTr']");
        if (tr.css("display") == "none"){
            tr.show("fast");
            a.html("-");
        } else {
            tr.each(function(){
                var childA = $(this).find("a");
                var childTr = $("#" + childA.prop("id") + "SubTr");
                childTr.hide();
                childA.html("+");
            });
            tr.hide("fast");
            a.html("+");
        }
    }
    function showSubElement(obj){
        var a = $(obj);
        var tr = $("#" + a.prop("id") + "SubTr");
        if (tr.css("display") == "none"){
            tr.show("fast");
            a.html("-");
        } else {
            tr.hide("fast");
            a.html("+");
        }
    }
    function showOtherElement(obj, line){
        var a = $(obj);
        var tr = $("tr[name='" + a.prop("id") + "SubTr']");
        if (tr.css("display") == "none"){
            tr.show("fast");
            a.html("-");
        } else {
            var trs = tr.parent().find("tr");
            trs.each(function(){
                if ($(this).prop("id") == "otherTextEvaluationTr" + line || $(this).prop("id") == "otherTextEvaluationSubTr" + line){
                    $(this).hide("fast");
                }
                if ($(this).prop("id") == "otherTextEvaluationTr" + line){
                    var childA = $(this).find("a");
                    childA.html("+");
                }
            });
            tr.hide("fast");
            a.html("+");
        }
    }
    function showOtherSubElement(obj){
        var a = $(obj);
        var tr = $("tr[name='" + a.prop("id") + "SubTr']");
        if (tr.css("display") == "none"){
            tr.show("fast");
            a.html("-");
        } else {
            tr.hide("fast");
            a.html("+");
        }
    }
    function showMessage(message){
        $('#msg').val(message);
        $('#infoDiv').show("fast");
    }
     function hiddenInfo(){
        $('#infoDiv').hide("fast");
    }
</script>
[@b.foot/]
