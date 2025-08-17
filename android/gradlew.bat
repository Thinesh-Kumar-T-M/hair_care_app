@echo off
rem Gradle wrapper script for Windows

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.

set GRADLE_HOME=%DIRNAME%gradle\wrapper\gradle-wrapper.jar
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_251

if not exist "%GRADLE_HOME%" (
    echo "Gradle wrapper jar not found. Please ensure it is present in the gradle/wrapper directory."
    exit /b 1
)

java -jar "%GRADLE_HOME%" %*