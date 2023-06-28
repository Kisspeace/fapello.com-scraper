unit Fapello.Parser;

interface

uses
  sysutils,
  HtmlParserEx { htmlparser - https://github.com/ying32/htmlparser },
  Fapello.types;

  function ParseThumbsFromNode(ANode: IHtmlElement): TFapelloThumbAr;
  function ParseThumbsFromPage(const ASource: string): TFapelloThumbAr;
  function ParseFeedItemsFromPage(const ASource: string): TFapelloFeedItemAr;
  function ParseAuthorPage(const ASource: string): TFapelloAuthorPage;
  function ParseFullPage(const ASource: string): TFapelloContentPage;

  function ParseAuthorUsername(AUrl: string): string;

implementation

function ParseThumbsFromNode(ANode: IHtmlElement): TFapelloThumbAr;
var
  LThumbs: IHTMLElementList;
  LThumb: IHTMLElement;
begin
  Result := [];
  LThumbs := ANode.FindX('div/a');
  for LThumb in LThumbs do begin
    var LNew: TFapelloThumb := TFapelloThumb.New();

    { Url }
    LNew.FullPageUrl := LThumb.Attributes['href'];

    { Thumbnail }
    LNew.ThumbnailUrl := LThumb.FindX('div/img')[0].Attributes['src'];

    Result := Result + [Lnew];
  end;
end;

function ParseThumbsFromPage(const ASource: string): TFapelloThumbAr;
var
  Doc: IHTMLElement;
  Body: IHTMLElement;
begin
  Doc := ParserHTML(ASource);
  try
    Body := Doc.FindX('body').Items[0];
    Result := ParseThumbsFromNode(Body);
  except
    Result := [];
  end;
end;

function ParseFeedItemsFromPage(const ASource: string): TFapelloFeedItemAr;
var
  Doc: IHtmlElement;
  LItems: IHtmlElementList;
  LItem: IHtmlElement;
  LTmp: IHtmlElement;
begin
  Result := [];
  Doc := ParserHTML(ASource);
  LItems := Doc.FindX('body/*[@class="bg-white"]');

  for LItem in LItems do begin
    var LNew := TFapelloFeedItem.New;
    var LTmps := LItem.FindX('div/div/a');

    { Author Url and username }
    LNew.Author.Url := LTmps[0].Attributes['href'];
    LNew.Author.Username := ParseAuthorUsername(LNew.Author.Url);

    { Author name }
    LNew.Author.DisplayName := trim(LTmps[1].FindX('span')[0].InnerText);

    { Author avatar }
    LNew.Author.AvatarUrl := LTmps[0].FindX('//img')[0].Attributes['src'];

    { Thumbnails }
    LTmps := LItem.FindX('//*[@class="img_feed"]');
    for LTmp in LTmps do
      LNew.Thumbnails := LNew.Thumbnails + [LTmp.Attributes['src']];

    if Length(Lnew.Thumbnails) < 1 then begin
      LTmps := LItem.FindX('//*[@class="uk-align-center"]/img');
      for LTmp in LTmps do
      LNew.Thumbnails := LNew.Thumbnails + [LTmp.Attributes['src']];
    end;

    Result := Result + [LNew];
  end;
end;

function ParseAuthorPage(const ASource: string): TFapelloAuthorPage;
var
  Doc: IHtmlElement;
  LTmp: IHtmlElement;
begin
  Result := TFapelloAuthorPage.New;
  Doc := ParserHtml(ASource);

  var LMain := Doc.FindX('//*[@class="pro-container"]')[0];
  var Profile := LMain.FindX('//*[@class="flex-col items-center"]')[0];
  var ProfileAvatar := Profile.FindX('div/div/a')[0];

  { Author Url and Username }
  Result.Author.Url := ProfileAvatar.Attributes['href'];
  Result.Author.Username := ParseAuthorUsername(Result.Author.Url);

  { Author avatar }
  Result.Author.AvatarUrl := ProfileAvatar.FindX('//img')[0].Attributes['src'];

  { Author display name }
  Result.Author.DisplayName := Trim(Profile.FindX('//h2')[0].InnerText);

  { Author alt names }
  Result.Author.OtherNames := Trim(Profile.FindX('//p')[0].InnerText);

  { Author media count }
  var LCounters := Profile.FindX('//*[@class="divide-gray-300 divide-transparent divide-x grid grid-cols-2 lg:text-left lg:text-lg mt-3 text-center w-full dark:text-gray-100"]')[0];
  try
    var tmp: string := Trim(LCounters.Children[1].InnerText);
    tmp := Copy(Tmp, Low(Tmp), Length(Tmp) - Pos('Media', tmp));
    Result.Author.Media := StrToInt(tmp);
  except

  end;

  { Author Likes count }
  try
    var tmp: string := Trim(LCounters.Children[3].InnerText);
    tmp := Copy(Tmp, Low(Tmp), Length(Tmp) - Pos('Likes', tmp));
    Result.Author.Likes := StrToInt(tmp);
  except

  end;

  { Thumbnails }
  var LContent := LMain.FindX('//*[@id="content"]')[0];
  Result.Content := ParseThumbsFromNode(LContent);
end;

function ParseFullPage(const ASource: string): TFapelloContentPage;
begin
  Result := ParseFeedItemsFromPage(ASource)[0];
end;

function ParseAuthorUsername(AUrl: string): string;
const
  MODEL_DIR = 'model/';
var
  LPos: integer;
  Res: string;
begin
  Result := '';
  LPos := Aurl.IndexOf(MODEL_DIR);
  if (LPos <> -1) then begin
    Result := Copy(AUrl, LPos + Length(MODEL_DIR) + 1, Integer.MaxValue);
    if Result[high(Result)] = '/' then
      Result := Copy(Result, 0, length(Result) - 1);
  end else begin
    LPos := Aurl.IndexOf('://');
    if (LPos <> -1) then begin
      Res := copy(AUrl, LPos + 4, Integer.MaxValue);
      LPos := Res.IndexOf('/');
      if (LPos <> -1) then begin
        Result := Copy(Res, LPos + 2, Integer.MaxValue);
        if Result[high(Result)] = '/' then
          Result := Copy(Result, 0, length(Result) - 1);
      end;
    end;
  end;
end;

end.