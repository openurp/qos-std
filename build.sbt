import org.openurp.parent.Settings._
import org.openurp.parent.Dependencies._
import org.beangle.tools.sbt.Sas

ThisBuild / organization := "org.openurp.qos.std"
ThisBuild / version := "0.0.21-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/qos-std"),
    "scm:git@github.com:openurp/qos-std.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id    = "chaostone",
    name  = "Tihua Duan",
    email = "duantihua@gmail.com",
    url   = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "OpenURP QoS Std"
ThisBuild / homepage := Some(url("http://openurp.github.io/qos-std/index.html"))

val apiVer = "0.26.0"
val starterVer = "0.0.21"
val baseVer = "0.1.30"
val evaluteVer="0.0.21-SNAPSHOT"
val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_qos_api = "org.openurp.qos" % "openurp-qos-api" % apiVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer
val openurp_qos_evaluate_core = "org.openurp.qos.evaluation" % "openurp-qos-evaluation-core" % evaluteVer
lazy val root = (project in file("."))
  .aggregate(evaluationapp)

lazy val evaluationapp = (project in file("evaluationapp"))
  .enablePlugins(WarPlugin,TomcatPlugin)
  .settings(
    name := "openurp-qos-std-evaluationapp",
    common,
    libraryDependencies ++= Seq(openurp_edu_api,openurp_qos_api,beangle_ems_app),
    libraryDependencies ++= Seq(openurp_stater_web,openurp_base_tag),
    libraryDependencies ++= Seq(openurp_qos_evaluate_core)
  )

publish / skip := true





