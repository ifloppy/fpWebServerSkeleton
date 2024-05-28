{
This is a demo for FPHTTPServer.

You can build your web application base on this project.
You can also copy code from this project.

This file is based on console application of Lazarus.

Author: github.com/ifloppy
Distributed under MIT license.
}

program fpWebServerSkeleton;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  SysUtils,
  CustApp,
  fphttpserver,
  httproute,
  HTTPDefs,
  httpprotocol,
  { you can add units after this }
  opensslsockets, {needed if you enabled SSL}
  {Routes}
  GetServerInfo in 'routes/getserverinfo.pas',
  echo in 'routes/echo';

type

  { TWebServerApp }

  TWebServerApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  private
    procedure HTTPRequestHandler(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
    procedure RootRoute(ARequest: TRequest; AResponse: TResponse);
    procedure DefaultRoute(ARequest: TRequest; AResponse: TResponse);
  end;

var
  //Options
  sPort: integer = 8080;
  sAddress: string = '0.0.0.0';
  sCertificate, sPrivateKey: string;

  //Server
  srv: TFPHttpServer;



  { TWebServerApp }

  procedure TWebServerApp.DoRun;
  var
    ErrorMsg: string;
  begin
    // quick check parameters
    ErrorMsg := CheckOptions('h', 'help');
    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

    // parse parameters
    if HasOption('h', 'help') then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    //Init server var
    srv := TFPHttpServer.Create(Self);

    if HasOption('p', 'port') then sPort := StrToInt(GetOptionValue('p', 'port'));
    if HasOption('h', 'host') then sAddress := GetOptionValue('h', 'host');

    if HasOption('--certificate') and HasOption('--private-key') then
    begin
      sCertificate := GetOptionValue('--certificate');
      sPrivateKey := GetOptionValue('--private-key');
      srv.UseSSL := True;
      with srv.CertificateData do
      begin
        HostName := sAddress;
        Certificate.FileName := sCertificate;
        PrivateKey.FileName := sPrivateKey;
      end;

    end;


    srv.Address := sAddress;
    srv.Port := sPort;
    srv.OnRequest := @HTTPRequestHandler;

    srv.ThreadMode := tmThreadPool;
    srv.ServerBanner := 'Free Pascal Web Server Demo';

    //Register Routes
    //If no route exists, it will throw an exception
    HTTPRouter.RegisterRoute('/', @RootRoute, False);
    HTTPRouter.RegisterRoute('/404', @DefaultRoute, True);



    WriteLn('Server starting on: ', sAddress, ':', sPort);

    srv.Active := True;

    // stop program loop
    Terminate;
  end;

  constructor TWebServerApp.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TWebServerApp.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TWebServerApp.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
    writeln('------Server Info------');
    writeln('Server Port: -p --port');
    writeln('Server Host: -h --host');
    writeln('------SSL(Optional)------');
    writeln('Certificate Path: --certificate');
    writeln('Private Key Path: --private-key');
    writeln('');
    writeln('');
    writeln('');

  end;

  procedure TWebServerApp.HTTPRequestHandler(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest; var AResponse: TFPHTTPConnectionResponse);
  begin

    //Your middle ware here
    //You can also wrap it into another procedure
    AResponse.ContentType := 'text/plain';//Global ContentType for this demo app


    //Authentication
    if LeftStr(ARequest.URI, 4) = '/api' then
    begin
      //Demo auth
      if ARequest.GetHeader(hhAuthorization) <> 'aaa' then
      begin
        AResponse.Content := 'You''re not authenticated';
        AResponse.SetStatus(401);
        Exit;
      end;


    end;

    //Routing
    try
      HTTPRouter.RouteRequest(ARequest, AResponse);
    except
      On E: Exception do
      begin
        WriteLn('Internal Error: ', E.Message);
      end;
    end;

  end;

  procedure TWebServerApp.RootRoute(ARequest: TRequest; AResponse: TResponse);
  begin
    AResponse.Content := 'Welcome to this demo web server.' + LineEnding +
      'Your IP address is:' + ARequest.RemoteAddress + LineEnding +
      'Your User-Agent is:' + ARequest.UserAgent + LineEnding +
      'See also: https://wiki.freepascal.org/Networking';

  end;

  procedure TWebServerApp.DefaultRoute(ARequest: TRequest; AResponse: TResponse);
  begin
    AResponse.Content := 'Welcome to this demo web server. But 404 Not Found!' +
      LineEnding + 'Your IP address is:' + ARequest.RemoteAddress +
      LineEnding + 'Your User-Agent is:' + ARequest.UserAgent + LineEnding +
      'See also: https://wiki.freepascal.org/Networking';
    AResponse.SetStatus(404);
  end;

var
  Application: TWebServerApp;
begin
  Application := TWebServerApp.Create(nil);
  Application.Title := 'Web Server Application';
  Application.Run;
  Application.Free;
end.
