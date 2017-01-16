unit domainwhois_controller;

{$mode objfpc}{$H+}

interface

uses
  whois_integration, dateutils, common, RegExpr,
  Classes, SysUtils;

const
  _WHOIS_CACHE_PATH = 'ztemp/cache/domains/';
  _WHOIS_CACHE_EXTENSION = '.txt';

type

  { TDomainWhoisController }

  TDomainWhoisController = class
  private
    Whois: TWhoisIntegration;
  public
    constructor Create;
    destructor Destroy;

    function whoisHandler(const IntentName: string; Params: TStrings): string;
  end;

implementation

{ TDomainWhoisController }

constructor TDomainWhoisController.Create;
begin
end;

destructor TDomainWhoisController.Destroy;
begin
end;

function TDomainWhoisController.whoisHandler(const IntentName: string;
  Params: TStrings): string;
var
  i: integer;
  s, domainName, cacheFile: string;
  forceWhois: boolean;
begin
  domainName := Params.Values['domain_value'];
  if not isDomain(domainName) then
  begin
    Result := 'sepertinya nama domain tidak valid';
    Exit;
  end;

  Result := 'finding ' + domainName;

  cacheFile := _WHOIS_CACHE_PATH + domainName + _WHOIS_CACHE_EXTENSION;

  Whois := TWhoisIntegration.Create;
  try
    forceWhois := False;
    if FileExists(cacheFile) then
    begin
      i := HoursBetween(FileDateToDateTime(FileAge(cacheFile)), now);
      if i = 0 then
        Whois.Data.LoadFromFile(cacheFile)
      else
        forceWhois := True;
    end
    else
      forceWhois := True;

    if forceWhois then
    begin
      if not Whois.Find(domainName) then
      begin
        Result := 'gagal mendapatkan informasi whois domain ' + domainName;
        Exit;
      end;
      Whois.Data.SaveToFile(cacheFile);
    end;

    Result := 'Domain: ' + UpperCase( domainName)
      + '\nRegistrar: ' + Whois.Registrar
      + '\nStatus: ' + Whois.Status
      + '\nUpdated Date: ' + Whois.UpdatedDate
      + '\nCreation Date: ' + Whois.CreationDate
      + '\nExpiration Date: ' + Whois.ExpiredDate
      + '\nName Server: ' + Whois.NameServer;
  except
    on E: Exception do
    begin
      Result := 'failed: ' + E.Message;
    end;
  end;
  Whois.Free;

end;

end.







