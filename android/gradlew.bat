@echo off
rem Gradle wrapper script for Windows

set DIR=%~dp0
if "%DIR%"=="" set DIR=.

set WRAPPER_JAR=%DIR%gradle\wrapper\gradle-wrapper.jar
set GRADLE_USER_HOME=%DIR%\.gradle

java -jar "%WRAPPER_JAR%" %*