unit Fapello.Types;

interface
uses
  sysutils;

type

  TFapelloAuthor = record
    Username: string;
    DisplayName: string;
    Url: string;
    AvatarUrl: string; { Can be empty }
    OtherNames: string; { From author page. It broken sometimes. }
    Media: Cardinal; { From author page }
    Likes: Cardinal; { From author page }
    class function New(AUsername: string = ''): TFapelloAuthor; static;
  end;

  TFapelloFeedItem = record
    Author: TFapelloAuthor;
//    Likes: cardinal;
    Thumbnails: TArray<string>;
    class function New: TFapelloFeedItem; static;
  end;

  TFapelloFeedItemAr = TArray<TFapelloFeedItem>;

  TFapelloThumb = record
    ThumbnailUrl: string;
    FullPageUrl: string;
    class function New: TFapelloThumb; static;
  end;

  TFapelloThumbAr = TArray<TFapelloThumb>;

  TFapelloAuthorPage = record
    Author: TFapelloAuthor;
    Content: TFapelloThumbAr;
    class function New: TFapelloAuthorPage; static;
  end;

  TFapelloContentPage = TFapelloFeedItem;
  { TFapelloContentPage.Thumbnails[0] - is a full sized image url }

implementation


{ TFapelloAuthor }

class function TFapelloAuthor.New(AUsername: string): TFapelloAuthor;
begin
  Result.Username := AUsername;
  Result.DisplayName := Result.Username;
  Result.Url := '';
  Result.AvatarUrl := '';
  Result.OtherNames := '';
  Result.Media := 0;
  Result.Likes := 0;
end;

{ TFapelloFeedItem }

class function TFapelloFeedItem.New: TFapelloFeedItem;
begin
//  Result.Likes := 0;
  Result.Author := TFapelloAuthor.New('');
  REsult.Thumbnails := [];
end;

{ TFapelloThumb }

class function TFapelloThumb.New: TFapelloThumb;
begin
  Result.ThumbnailUrl := '';
  Result.FullPageUrl := '';
end;

{ TFapelloAuthorPage }

class function TFapelloAuthorPage.New: TFapelloAuthorPage;
begin
  Result.Author := TFapelloAuthor.New('');
  Result.Content := [];
end;

end.