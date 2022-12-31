unit Fapello.Scraper;
interface
uses
  classes, Sysutils, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  system.Generics.Collections,
  Fapello.parser, Fapello.types;

const
  BASE_URL = 'https://fapello.com';

type

  TFapelloScraper = class(TObject)
    private const
      DEFAULT_HOST = BASE_URL;
    private
      FHost: string;
    public
      Client: TNetHttpClient;
      function GetAuthorContent(AUsername: string; APage: cardinal = 1): TFapelloThumbAr; overload;
      function GetAuthorContent(AAuthor: TFapelloAuthor; APage: cardinal = 1): TFapelloThumbAr; overload;
      function GetAuthorPage(AUsername: string): TFapelloAuthorPage; overload;
      function GetAuthorPage(AAuthor: TFapelloAuthor): TFapelloAuthorPage; overload;
      function GetFeedItems(APage: cardinal = 1): TFapelloFeedItemAr;
      function GetFullContent(AUrl: string): TFapelloContentPage; overload;
      function GetFullContent(AThumb: TFapelloThumb): TFapelloContentPage; overload;
      {* --------- *}
      property Host: string read FHost write FHost;
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TCoomerPartyScraper }

constructor TFapelloScraper.Create;
begin
  Client := TNetHttpClient.Create(Nil);
  Client.Asynchronous := false;
  FHost := DEFAULT_HOST;
end;

destructor TFapelloScraper.Destroy;
begin
  Client.Free;
  inherited;
end;

function TFapelloScraper.GetAuthorContent(AUsername: string;
  APage: cardinal): TFapelloThumbAr;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/ajax/model/' + AUsername + '/page-' + APage.ToString + '/').ContentAsString;
  Result := ParseThumbsFromPage(LContent);
end;

function TFapelloScraper.GetAuthorPage(
  AUsername: string): TFapelloAuthorPage;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/' + AUsername + '/').ContentAsString;
  Result := ParseAuthorPage(LContent);
end;

function TFapelloScraper.GetFeedItems(APage: cardinal): TFapelloFeedItemAr;
var
  LContent: string;
begin
  LContent := Client.Get(Self.Host + '/ajax/index/page-' + APage.ToString + '/').ContentAsString;
  Result := ParseFeedItemsFromPage(LContent);
end;

function TFapelloScraper.GetFullContent(
  AThumb: TFapelloThumb): TFapelloContentPage;
begin
  Result := Self.GetFullContent(AThumb.FullPageUrl);
end;

function TFapelloScraper.GetFullContent(AUrl: string): TFapelloContentPage;
var
  LContent: string;
begin
  LContent := Self.Client.Get(AUrl).ContentAsString;
  Result := ParseFullPage(LContent);
end;

function TFapelloScraper.GetAuthorContent(AAuthor: TFapelloAuthor;
  APage: cardinal): TFapelloThumbAr;
begin
  Result := Self.GetAuthorContent(AAuthor.Username, APage);
end;

function TFapelloScraper.GetAuthorPage(
  AAuthor: TFapelloAuthor): TFapelloAuthorPage;
begin
  Result := Self.GetAuthorPage(AAuthor.Username);
end;

end.