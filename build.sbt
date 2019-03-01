ThisBuild / scalaVersion := "2.12.8"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "example"
ThisBuild / organizationName := "example"

lazy val root = (project in file("."))
  .enablePlugins(JavaAppPackaging, DockerPlugin)
  .settings(
    name := "geotrellis-gdal-example",
    libraryDependencies ++= Seq(
      "org.locationtech.geotrellis" %% "geotrellis-raster" % "2.2.0",
      "com.azavea.geotrellis" %% "geotrellis-gdal" % "0.18.5-SNAPSHOT"
    ),
    mainClass in Compile := Some("example.GdalExample"),
    javaOptions in Universal ++= Seq("-Djava.library.path=/usr/local/lib/"),
    packageName in Docker := "geotrellis-gdal-example",
    dockerUpdateLatest := true,
    dockerBaseImage := "gdal-java"
  )

addCommandAlias("dpl", "docker:publishLocal")
addCommandAlias("dpr", "docker:publish")
