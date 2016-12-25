unit routes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fastplaz_handler;

implementation

uses info_controller, main, simplebot_controller;

initialization
  Route.Add( 'main', TMainModule);
  //Route.Add( 'coba', TSimpleBotModule);
  Route.Add( 'info', TInfoModule);

end.

