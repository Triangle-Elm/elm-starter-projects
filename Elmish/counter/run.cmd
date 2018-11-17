@cd %~dp0
call npm install
dotnet restore src
cd src
dotnet fable webpack-dev-server

