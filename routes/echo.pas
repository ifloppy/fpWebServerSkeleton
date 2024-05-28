{
This is a demo for FPHTTPServer.

You can build your web application base on this project.
You can also copy code from this project.

This is route part.

Author: github.com/ifloppy
Distributed under MIT license.
}
unit echo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs;

implementation

uses httproute;

procedure Echo(ARequest: TRequest; AResponse: TResponse);
begin
  AResponse.Content := ARequest.RouteParams['cnt'];
end;

initialization

HTTPRouter.RegisterRoute('/echo/:cnt', rmGet, @Echo);

end.

