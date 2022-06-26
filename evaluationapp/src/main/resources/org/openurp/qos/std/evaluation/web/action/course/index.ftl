[#ftl]
[@b.head/]
<div class="container-fluid">
  [@b.toolbar title="课程问卷评教"/]
  <table width="100%"><tr><td class="index_content" >[@urp_base.semester_bar value=currentSemester/]</td></tr></table>
  <div class="search-list">
            [@b.div id="contentDiv"  href="!search?&semester.id=${currentSemester.id}" /]
  </div>
</div>
[@b.foot/]
