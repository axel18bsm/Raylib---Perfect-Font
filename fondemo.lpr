program OswaldDemo;
{
  ============================================================
  DEMO - Police Oswald avec Raylib + RayGUI en Pascal
  ------------------------------------------------------------
  Compatible  : FPC 3.2.2 + Object Pascal
  Amelioration: TColor constants + TEXTURE_FILTER_ANISOTROPIC_4X
  Requis      : raylib.dll, Oswald-Regular.ttf, Oswald-Bold.ttf
  ============================================================
}

uses
  raylib,
  raygui;

{ ============================================================ }
{                     CONSTANTES                               }
{ ============================================================ }
const
  SCREEN_W  = 900;
  SCREEN_H  = 620;
  APP_TITLE = 'Wargame - Demo Police Oswald';

  SIZE_TITRE = 72;
  SIZE_SOUS  = 36;
  SIZE_CORPS = 26;
  SIZE_PETIT = 20;

  SPACING_TITRE = 3.0;
  SPACING_CORPS = 1.5;

  { ---- Palette de couleurs TColor pour ce projet ---- }
  { Bleu nuit fonce  : fond haut }
  COL_FOND_HAUT  : TColor = (r:$0A; g:$16; b:$28; a:$FF);
  { Bleu nuit moyen  : fond bas }
  COL_FOND_BAS   : TColor = (r:$1A; g:$2C; b:$44; a:$FF);
  { Bleu acier       : lignes et bordures }
  COL_ACIER      : TColor = (r:$4A; g:$90; b:$D9; a:$FF);
  { Bleu acier demi  : separateurs }
  COL_ACIER_MI   : TColor = (r:$4A; g:$90; b:$D9; a:$66);
  { Bleu acier leger : ligne titre }
  COL_ACIER_LG   : TColor = (r:$4A; g:$90; b:$D9; a:$AA);
  { Blanc nacre      : titre principal }
  COL_TITRE      : TColor = (r:$E8; g:$F4; b:$FF; a:$FF);
  { Bleu gris clair  : corps de texte }
  COL_CORPS      : TColor = (r:$C8; g:$D8; b:$E8; a:$FF);
  { Bleu gris allies }
  COL_ALLIES     : TColor = (r:$90; g:$B8; b:$D0; a:$FF);
  { Rose gris ennemis }
  COL_ENNEMIS    : TColor = (r:$D0; g:$80; b:$90; a:$FF);
  { Bouton normal    }
  COL_BTN_NORMAL : TColor = (r:$1A; g:$3A; b:$5C; a:$FF);
  { Bouton survole   }
  COL_BTN_FOCUS  : TColor = (r:$2A; g:$5A; b:$8C; a:$FF);
  { Bouton presse    }
  COL_BTN_PRESS  : TColor = (r:$4A; g:$90; b:$D9; a:$FF);
  { Fond bouton presse texte }
  COL_BTN_TXT_PR : TColor = (r:$0A; g:$16; b:$28; a:$FF);

{ ============================================================ }
{                  VARIABLES GLOBALES                          }
{ ============================================================ }
var
  fontRegular : TFont;
  fontBold    : TFont;
  frameCount  : Integer;

{ ============================================================ }
{  WRAPPER GuiButton : retourne Boolean depuis LongInt         }
{ ============================================================ }
function BoutonClique(bounds: TRectangle; const texte: PChar): Boolean;
begin
  Result := (GuiButton(bounds, texte) = 1);
end;

{ ============================================================ }
{   Charger les polices avec TEXTURE_FILTER_ANISOTROPIC_4X     }
{   Meilleure qualite que BILINEAR, surtout en angle et        }
{   pour les petites tailles de texte TEXTURE_FILTER_BILINEAR                         }
{ ============================================================ }
procedure ChargerPolices;
begin
  fontRegular := LoadFontEx('Oswald-Regular.ttf', 128, nil, 0);
  SetTextureFilter(fontRegular.texture, TEXTURE_FILTER_BILINEAR);  { <- ici TEXTURE_FILTER_ANISOTROPIC_4X }

  fontBold := LoadFontEx('Oswald-Bold.ttf', 128, nil, 0);
  SetTextureFilter(fontBold.texture, TEXTURE_FILTER_BILINEAR);     { <- et ici TEXTURE_FILTER_ANISOTROPIC_4X }

  GuiSetFont(fontRegular);
  GuiSetStyle(DEFAULT, TEXT_SIZE, 22);
  GuiSetStyle(DEFAULT, TEXT_COLOR_NORMAL, ColorToInt(WHITE));
end;

{ ============================================================ }
{   Style boutons RayGUI avec TColor                           }
{ ============================================================ }
procedure AppliquerStyleBoutons;
begin
  GuiSetStyle(BUTTON, BASE_COLOR_NORMAL,  ColorToInt(COL_BTN_NORMAL));
  GuiSetStyle(BUTTON, BASE_COLOR_FOCUSED, ColorToInt(COL_BTN_FOCUS));
  GuiSetStyle(BUTTON, BASE_COLOR_PRESSED, ColorToInt(COL_BTN_PRESS));
  GuiSetStyle(BUTTON, TEXT_COLOR_NORMAL,  ColorToInt(WHITE));
  GuiSetStyle(BUTTON, TEXT_COLOR_FOCUSED, ColorToInt(WHITE));
  GuiSetStyle(BUTTON, TEXT_COLOR_PRESSED, ColorToInt(COL_BTN_TXT_PR));
  GuiSetStyle(BUTTON, BORDER_WIDTH, 2);
end;

{ ============================================================ }
{   Fond degrade avec TColor                                   }
{ ============================================================ }
procedure DessinerFond;
var
  i  : Integer;
  t  : Single;
  r, g, b : Integer;
begin
  { Degrade COL_FOND_HAUT -> COL_FOND_BAS }
  for i := 0 to SCREEN_H - 1 do
  begin
    t := i / SCREEN_H;
    r := Round(COL_FOND_HAUT.r + (COL_FOND_BAS.r - COL_FOND_HAUT.r) * t);
    g := Round(COL_FOND_HAUT.g + (COL_FOND_BAS.g - COL_FOND_HAUT.g) * t);
    b := Round(COL_FOND_HAUT.b + (COL_FOND_BAS.b - COL_FOND_HAUT.b) * t);
    DrawLine(0, i, SCREEN_W, i, ColorCreate(r, g, b, 255));
  end;

  { Ligne decorative sous le titre }
  DrawRectangle(0, 130, SCREEN_W, 2, COL_ACIER_LG);
  DrawRectangle(0, 132, SCREEN_W, 1, ColorAlpha(RAYWHITE, 0.13));

  { Ligne bas de page }
  DrawRectangle(0, SCREEN_H - 80, SCREEN_W, 1, COL_ACIER_MI);

  { Barre laterale decorative }
  DrawRectangle(40, 150, 4, SCREEN_H - 230, COL_ACIER);
end;

{ ============================================================ }
{   Textes avec TColor                                         }
{ ============================================================ }
procedure DessinerTextes;
var
  pulse        : Single;
  couleurTitre : TColor;
begin
  { Pulsation douce du titre }
  pulse := 0.85 + 0.15 * Sin(frameCount * 0.03);
  couleurTitre := ColorAlpha(COL_TITRE, pulse);

  { --- TITRE --- }
  DrawTextEx(fontBold,
    'WARGAME TACTIQUE',
    Vector2Create(50, 35),
    SIZE_TITRE,
    SPACING_TITRE,
    couleurTitre);

  { --- SOUS-TITRE --- }
  DrawTextEx(fontRegular,
    'Campagne : Front de l''Est  -  1943',
    Vector2Create(52, 142),
    SIZE_SOUS,
    SPACING_CORPS,
    COL_ACIER);           { <- TColor direct, plus de GetColor() }

  { --- EN-TETE --- }
  DrawTextEx(fontRegular,
    'RAPPORT DE SITUATION',
    Vector2Create(58, 188),
    SIZE_CORPS + 2,
    SPACING_CORPS,
    GOLD);                { <- constante Raylib directe }

  { --- Corps --- }
  DrawTextEx(fontRegular,
    'Les forces blindees alliees progressent sur l''axe Nord-Est.',
    Vector2Create(58, 224),
    SIZE_CORPS, SPACING_CORPS,
    COL_CORPS);

  DrawTextEx(fontRegular,
    'La 3eme division d''infanterie tient ses positions malgre',
    Vector2Create(58, 256),
    SIZE_CORPS, SPACING_CORPS,
    COL_CORPS);

  DrawTextEx(fontRegular,
    'les contre-attaques ennemies au secteur Delta-7.',
    Vector2Create(58, 288),
    SIZE_CORPS, SPACING_CORPS,
    COL_CORPS);

  { Separateur }
  DrawRectangle(58, 328, 400, 1, COL_ACIER_MI);

  { --- Statistiques --- }
  DrawTextEx(fontRegular,
    'EFFECTIFS',
    Vector2Create(58, 340),
    SIZE_PETIT + 2, SPACING_CORPS,
    GOLD);                { <- GOLD = $FFD700 directement }

  DrawTextEx(fontRegular,
    'Allies  :  12 500 h.  |  Chars : 340  |  Artillerie : 85',
    Vector2Create(58, 366),
    SIZE_PETIT, SPACING_CORPS,
    COL_ALLIES);

  DrawTextEx(fontRegular,
    'Ennemis :   9 800 h.  |  Chars : 210  |  Artillerie : 60',
    Vector2Create(58, 392),
    SIZE_PETIT, SPACING_CORPS,
    COL_ENNEMIS);

  { --- Pied de page --- }
  DrawTextEx(fontRegular,
    'Appuyez sur [ECHAP] pour quitter',
    Vector2Create(58, SCREEN_H - 52),
    SIZE_PETIT, SPACING_CORPS,
    ColorAlpha(RAYWHITE, 0.35));  { <- RAYWHITE a la place de WHITE }

  DrawTextEx(fontRegular,
    'Raylib  |  Oswald Font  |  ANISOTROPIC_4X  |  FPC 3.2.2',
    Vector2Create(SCREEN_W - 440, SCREEN_H - 52),
    SIZE_PETIT - 2, SPACING_CORPS,
    ColorAlpha(RAYWHITE, 0.22));
end;

{ ============================================================ }
{   Boutons RayGUI                                             }
{ ============================================================ }
procedure DessinerBoutonsGUI;
begin
  AppliquerStyleBoutons;

  if BoutonClique(RectangleCreate(600, 200, 250, 50), 'NOUVELLE PARTIE') then
    TraceLog(LOG_INFO, 'Nouvelle Partie !');

  if BoutonClique(RectangleCreate(600, 265, 250, 50), 'CHARGER PARTIE') then
    TraceLog(LOG_INFO, 'Charger !');

  if BoutonClique(RectangleCreate(600, 330, 250, 50), 'OPTIONS') then
    TraceLog(LOG_INFO, 'Options !');

  if BoutonClique(RectangleCreate(600, 395, 250, 50), 'QUITTER') then
    CloseWindow;
end;

{ ============================================================ }
{                   PROGRAMME PRINCIPAL                        }
{ ============================================================ }
begin
  SetConfigFlags(FLAG_WINDOW_RESIZABLE or FLAG_MSAA_4X_HINT);
  InitWindow(SCREEN_W, SCREEN_H, APP_TITLE);
  SetTargetFPS(60);
  SetExitKey(KEY_ESCAPE);

  ChargerPolices;
  frameCount := 0;

  while not WindowShouldClose do
  begin
    Inc(frameCount);
    BeginDrawing;
      DessinerFond;
      DessinerTextes;
      DessinerBoutonsGUI;
      DrawFPS(SCREEN_W - 90, 10);
    EndDrawing;
  end;

  UnloadFont(fontRegular);
  UnloadFont(fontBold);
  CloseWindow;
end.
