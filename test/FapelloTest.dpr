program FapelloTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Classes,
  Net.HttpClient,
  Net.HttpClientComponent,
  Fapello.Scraper in '..\source\Fapello.Scraper.pas',
  Fapello.Parser in '..\source\Fapello.Parser.pas',
  Fapello.Types in '..\source\Fapello.Types.pas';

const
  OFFLINE_PARSER_TEST: boolean = False;
  ONLINE_SCRAPER_TEST: boolean = True;

function NewScraper: TFapelloScraper;
begin
  Result := TFapelloScraper.Create;
  with Result.Client do begin
    Asynchronous := false;
    AutomaticDecompression := [THttpCompressionMethod.Any];
    AllowCookies := false;
    Useragent                        := 'Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0';
    Customheaders['Accept']          := 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    CustomHeaders['Accept-Language'] := 'en-US,en;q=0.5';
    CustomHeaders['Accept-Encoding'] := 'gzip, deflate';
    CustomHeaders['DNT']             := '1';
    CustomHeaders['Connection']      := 'keep-alive';
    CustomHeaders['Upgrade-Insecure-Requests'] := '1';
    CustomHeaders['Sec-Fetch-Dest']  := 'document';
    CustomHeaders['Sec-Fetch-Mode']  := 'navigate';
    CustomHeaders['Sec-Fetch-Site']  := 'same-origin';
    CustomHeaders['Pragma']          := 'no-cache';
    CustomHeaders['Cache-Control']   := 'no-cache';
  end;
end;

procedure PrintThumbs(AThumbs: TFapelloThumbAr);
var
  I: integer;
begin
  for I := 0 to High(AThumbs) do begin
    writeln((I+1).ToString + ' ) ' + AThumbs[I].ThumbnailUrl + ' : ' + AThumbs[I].FullPageUrl);
  end;
end;

procedure PrintAuthor(AAuthor: TFapelloAuthor);
begin
  Writeln('Author: ' + AAuthor.DisplayName + '(' + AAuthor.Username + ') : ' + AAuthor.Url);
  Writeln('Avatar: ' + AAuthor.AvatarUrl);
end;

procedure PrintFeedItem(AFeed: TFapelloFeedItem);
var
  N: integer;
begin
  PrintAuthor(AFeed.Author);
  for N := 0 to High(AFeed.Thumbnails) do
    Writeln('Thumb: ' + AFeed.Thumbnails[N]);
end;

procedure PrintFeedItems(AFeed: TFapelloFeedItemAr);
var
  I, N: integer;
begin
  for I := 0 to High(AFeed) do begin
    Writeln((I+1).ToString + ' ) ---------------------------------|');
    PrintFeedItem(AFeed[I]);
  end;
end;

procedure PrintAuthorPage(APage: TFapelloAuthorPage);
begin
  PrintAuthor(APage.Author);
  Writeln('AltNames: ' + APage.Author.OtherNames);
  Writeln('Media count: ' + APage.Author.Media.ToString + ', Likes count: ' + APage.Author.Likes.ToString);
  PrintThumbs(APage.Content);
end;

function FileContent(AFilename: string): string;
var
  Lstrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.LoadFromFile(AFilename);
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

procedure TestParserOffline;
var
  LTmp: string;
begin
  try
    Write('GetFeedItems: ');
    LTmp := FileContent('feed.html');
    var Feed := ParseFeedItemsFromPage(LTmp);
    if Length(Feed) > 0 then begin
      Writeln('OK: ' + Length(Feed).ToString + ' items.');
      PrintFeedItems(Feed);
    end else
      Writeln('ERROR');
  except On E: exception do
    Writeln(E.ToString);
  end;

  try
    Write('GetAuthorPage: ');
    LTmp := FileContent('author_page.html');
    var AuthorPage := ParseAuthorPage(LTmp);
    if Length(AuthorPage.Author.Url) > 0 then begin
      Writeln('OK: ' + Length(AuthorPage.Content).ToString + ' items.');
      PrintAuthorPage(AuthorPage);
    end else
      Writeln('ERROR');
  except On E: exception do
    Writeln(E.ToString);
  end;

  try
    Write('GetFullContent: ');
    LTmp := FileContent('full.html');
    var Full: TFapelloFeedItem := ParseFullPage(Ltmp);
    if length(Full.Thumbnails) > 0 then begin
      Writeln('OK');
      PrintFeedItem(Full);
    end else
      Writeln('ERROR');
  except On E: exception do
    Writeln(E.ToString);
  end;

end;

var
  Fapello: TFapelloScraper;
begin
  try

    if OFFLINE_PARSER_TEST then begin
      TestParserOffline;
      Writeln('Parser tests finished.');
      Readln;
    end;

    if ONLINE_SCRAPER_TEST then begin

      Fapello := NewScraper;

      Write('GetFeedItems: ');
      var Feed := Fapello.GetFeedItems(1);
      if Length(Feed) > 0 then begin
        Writeln('OK: ' + Length(Feed).ToString + ' items.');
        PrintFeedItems(Feed);
      end else
        Writeln('ERROR');

      Write('GetAuthorPage: ');
      var AuthorPage := Fapello.GetAuthorPage('vinnegal');
      if Length(AuthorPage.Author.Url) > 0 then begin
        Writeln('OK: ' + Length(AuthorPage.Content).ToString + ' items.');
        PrintAuthorPage(AuthorPage);
      end else
        Writeln('ERROR');

      Write('GetAuthorContent: ');
      var Content := Fapello.GetAuthorContent(Feed[0].Author, 1);
      if length(Content) > 0 then begin
        Writeln('OK: ' + Length(Content).ToString + ' items.');
        PrintThumbs(Content);
      end else
        Writeln('ERROR');

      Write('GetFullContent: ');
      var Full: TFapelloFeedItem := Fapello.GetFullContent(Content[0]);
      if length(Full.Thumbnails) > 0 then begin
        Writeln('OK');
        PrintFeedItem(Full);
      end else
        Writeln('ERROR');

    end;

    Readln;

  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      readln;
    end;
  end;
end.
