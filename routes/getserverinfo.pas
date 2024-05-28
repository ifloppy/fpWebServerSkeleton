{
This is a demo for FPHTTPServer.

You can build your web application base on this project.
You can also copy code from this project.

This is route part.

Author: github.com/ifloppy
Distributed under MIT license.
}
unit GetServerInfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs;

implementation

uses httproute;

function GetSystemInfo: string;
var
  SystemTime: TSystemTime;
begin
  // 获取系统时钟信息
  GetLocalTime(SystemTime);

  // 构建返回的文本
  Result := 'System Time:' + Format('%02d:%02d:%02d', [SystemTime.wHour, SystemTime.wMinute, SystemTime.wSecond]);
end;



procedure GetServerInfo(ARequest: TRequest; AResponse: TResponse);
begin
  AResponse.ContentType := 'text/plain';
  AResponse.Content := GetSystemInfo;
end;

initialization

HTTPRouter.RegisterRoute('/srv_info', rmGet, @GetServerInfo);

end.

