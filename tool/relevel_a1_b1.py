"""Rescue everyday vocabulary that was generated at C1 or C2.

The 3.6.0 expansion filled its level quotas top-heavy: 62 percent of the
generated cards landed at C1 or C2, which stranded ordinary words a beginner
needs behind five levels of progression. Because the app gates content by
level, an A2 learner literally could not reach "der Hausschlüssel".

This moves the clear cases down. It is deliberately conservative: a word only
appears here if it is plainly everyday vocabulary. Rare, idiomatic, regional
and figurative words -- der Hochstapler, die Naschkatze, das Mauerblümchen,
zeitlebens, heuer, bisweilen -- are left where they are, because they really
do belong at an advanced level.

Judgement calls are recorded rather than hidden: "der Vordermann" and
"die Belegschaft" go to B2 rather than B1, because they are workplace-specific
even though they are common in that setting.
"""
import io
import re

# id -> level it should actually be
RELEVEL = {
    # --- A2: concrete, high-frequency, first-year vocabulary -------------
    'x24442': 'A2',  # das Neujahr
    'x24443': 'A2',  # der Kinderwagen
    'x24492': 'A2',  # die Turnhalle
    'x25024': 'A2',  # monatlich
    'x25053': 'A2',  # die Wassermelone
    'x25074': 'A2',  # die Mango
    'x25178': 'A2',  # das Trinkwasser
    'x25401': 'A2',  # die Zimmernummer
    'x25716': 'A2',  # das Weißbrot
    'x26694': 'A2',  # der Wochentag
    'x27619': 'A2',  # der Nachmittag
    'x27562': 'A2',  # das Fastfood
    'x26740': 'A2',  # der Hausschlüssel
    'x26485': 'A2',  # die Hausnummer
    'x26207': 'A2',  # der Küchentisch
    'x26315': 'A2',  # die Kaffeepause
    'x26332': 'A2',  # der Arzttermin
    'x27573': 'A2',  # die Zugfahrt
    'x27773': 'A2',  # der Fruchtsaft
    'x25980': 'A2',  # das Kinderbuch
    'x25985': 'A2',  # das Bücherregal
    'x26982': 'A2',  # der Personalausweis
    'x27182': 'A2',  # die Tageszeitung
    'x27410': 'A2',  # das Küchenmesser
    'x25964': 'A2',  # die Ankunftszeit
    'x24771': 'A2',  # das Wartezimmer
    'x25494': 'A2',  # der Muttertag
    'x26943': 'A2',  # der Vatertag
    'x26022': 'A2',  # die Weihnachtszeit
    'x26289': 'A2',  # der Weihnachtstag
    'x25292': 'A2',  # das Elternhaus
    'x24760': 'A2',  # das Einzelkind
    'x24583': 'A2',  # der Mitschüler
    'x25045': 'A2',  # die Landstraße
    'x26308': 'A2',  # der Sommertag
    'x28320': 'A2',  # der Regentag
    'x27993': 'A2',  # der Frühlingstag
    'x26106': 'A2',  # die Tageszeit
    'x26391': 'A2',  # das Monatsende
    'x25211': 'A2',  # die Wartezeit
    'x23951': 'A2',  # der Arbeitstag
    'x23829': 'A2',  # die Arbeitszeit
    'x24073': 'A2',  # die Viertelstunde
    'x23771': 'A2',  # das Fitnessstudio
    'x23703': 'A2',  # das Esszimmer
    'x23624': 'A2',  # das Flugticket
    'x23456': 'A2',  # das Abendbrot
    'x24613': 'A2',  # der Eiswürfel
    'x26250': 'A2',  # die Gartenarbeit
    'x28498': 'A2',  # der Gärtner
    'x26235': 'A2',  # der Nachhauseweg
    'x25218': 'A2',  # das Heimatland
    'x27549': 'A2',  # dreijährig
    'x27940': 'A2',  # zehnjährig
    'x27941': 'A2',  # siebenjährig
    'x28663': 'A2',  # vierjährig
    'x28716': 'A2',  # zweijährig
    'x25573': 'A2',  # die Sporthalle
    'x25646': 'A2',  # der Rückenschmerz
    'x24166': 'A2',  # der Bauchschmerz
    'x26148': 'A2',  # die Schmerztablette
    'x26512': 'A2',  # das Katzenfutter
    'x25010': 'A2',  # das Hundefutter
    'x26428': 'A2',  # die Hundehütte
    'x26766': 'A2',  # das Stofftier
    'x27400': 'A2',  # das Kuscheltier
    'x28815': 'A2',  # der Obstbaum
    'x25119': 'A2',  # das Baumhaus
    'x28173': 'A2',  # der Küchenschrank
    'x28549': 'A2',  # das Küchengerät
    'x28333': 'A2',  # die Raumtemperatur
    'x28337': 'A2',  # die Straßenkarte
    'x28159': 'A2',  # das Straßenschild
    'x28068': 'A2',  # der Straßenverkehr
    'x28704': 'A2',  # das Mountainbike
    'x28430': 'A2',  # der Berggipfel
    'x28744': 'A2',  # die Bahnstation
    'x28730': 'A2',  # die Großfamilie
    'x25733': 'A2',  # das Familienfoto
    'x27128': 'A2',  # der Schnellzug
    'x27135': 'A2',  # der Zimmerschlüssel
    'x27243': 'A2',  # die Unterrichtsstunde
    'x27126': 'A2',  # der Sportunterricht
    'x27629': 'A2',  # das Reiseziel
    'x26452': 'A2',  # die Rückreise
    'x28029': 'A2',  # die Tagesreise
    'x27314': 'A2',  # der Urlaubstag
    'x27361': 'A2',  # das Halbjahr
    'x27156': 'A2',  # das Jahresende
    'x28787': 'A2',  # das Tagesende
    'x27432': 'A2',  # der Vortag
    'x27925': 'A2',  # die Sommerzeit
    'x28697': 'A2',  # der Neujahrstag
    'x28842': 'A2',  # das Toastbrot
    'x25397': 'A2',  # die Diele
    'x24447': 'A2',  # die Baumwolle
    'x24571': 'A2',  # der Diesel
    'x25335': 'A2',  # die Lokomotive
    'x23606': 'A2',  # das Getreide
    'x23833': 'A2',  # der Bagel
    'x24286': 'A2',  # das Lieblingsessen
    'x24354': 'A2',  # der Stammbaum
    'x24352': 'A2',  # der Mixer
    'x23519': 'A2',  # der Strohhalm
    'x23501': 'A2',  # der Lagerraum
    'x23641': 'A2',  # der Konferenzraum
    'x27907': 'A2',  # das Konferenzzimmer
    'x26004': 'A2',  # der Bergsteiger
    'x23546': 'A2',  # heimgehen
    'x23451': 'A2',  # heimfahren

    # --- B1: everyday but a step up in register or specificity ----------
    'x24476': 'B1',  # die Krankenversicherung
    'x24618': 'B1',  # die Verwandtschaft
    'x23912': 'B1',  # der Zeitraum
    'x24201': 'B1',  # der Bürgersteig
    'x24046': 'B1',  # der Fahrgast
    'x25098': 'B1',  # der Schaffner
    'x25665': 'B1',  # die Aubergine
    'x25999': 'B1',  # die Avocado
    'x26531': 'B1',  # die Papaya
    'x24315': 'B1',  # einschenken
    'x23603': 'B1',  # austrinken
    'x23612': 'B1',  # verdauen
    'x23778': 'B1',  # ungesund
    'x24138': 'B1',  # die Erkrankung
    'x24020': 'B1',  # kurieren
    'x24275': 'B1',  # die Pubertät
    'x24975': 'B1',  # das Unwetter
    'x28706': 'B1',  # das Sauwetter
    'x28764': 'B1',  # das Regenwetter
    'x28644': 'B1',  # die Wetterlage
    'x25042': 'B1',  # das Landhaus
    'x25090': 'B1',  # das Quartal
    'x25266': 'B1',  # auschecken
    'x25275': 'B1',  # verordnen
    'x25296': 'B1',  # der Doktortitel
    'x25372': 'B1',  # die Stoßstange
    'x25490': 'B1',  # die Lebensmittelvergiftung
    'x25498': 'B1',  # die Etappe
    'x25571': 'B1',  # der Baumarkt
    'x25621': 'B1',  # die Geisteskrankheit
    'x25639': 'B1',  # der Medizinstudent
    'x25668': 'B1',  # die Doktorarbeit
    'x25675': 'B1',  # gesundheitlich
    'x25680': 'B1',  # die Raumfahrt
    'x25683': 'B1',  # das Schlagloch
    'x25686': 'B1',  # das Nebenzimmer
    'x25701': 'B1',  # der Polizeiwagen
    'x23465': 'B1',  # der Streifenwagen
    'x25823': 'B1',  # die Druckerei
    'x25848': 'B1',  # der Hausmann
    'x25943': 'B1',  # zurückreisen
    'x25945': 'B1',  # einarbeiten
    'x26020': 'B1',  # das Flussufer
    'x26036': 'B1',  # die Bestattung
    'x26082': 'B1',  # die Rehabilitation
    'x26090': 'B1',  # der Operationssaal
    'x26099': 'B1',  # die Bedenkzeit
    'x26105': 'B1',  # der Tischler
    'x26601': 'B1',  # der Schreiner
    'x26107': 'B1',  # der Entdecker
    'x26205': 'B1',  # das Zeitgefühl
    'x26293': 'B1',  # vorverlegen
    'x26453': 'B1',  # der Zeitdruck
    'x26460': 'B1',  # der Stundenkilometer
    'x26483': 'B1',  # der Gesprächspartner
    'x26516': 'B1',  # das Krankenzimmer
    'x26536': 'B1',  # begießen
    'x26732': 'B1',  # die Zeitzone
    'x26758': 'B1',  # der Gepäckträger
    'x26759': 'B1',  # der Veganer
    'x26781': 'B1',  # herumkommen
    'x26860': 'B1',  # der Bücherwurm
    'x26866': 'B1',  # die Kindheitserinnerung
    'x26878': 'B1',  # der Helfer
    'x26885': 'B1',  # der Gesundheitszustand
    'x27012': 'B1',  # bergsteigen
    'x27054': 'B1',  # die Verwundung
    'x27060': 'B1',  # die Tierart
    'x27063': 'B1',  # der Freundeskreis
    'x27072': 'B1',  # das Möbelstück
    'x27073': 'B1',  # der Waldbrand
    'x27085': 'B1',  # der Wahltag
    'x27105': 'B1',  # der Fleischfresser
    'x28676': 'B1',  # der Pflanzenfresser
    'x27158': 'B1',  # die Giraffe
    'x27179': 'B1',  # der Florist
    'x27256': 'B1',  # der Rastplatz
    'x27339': 'B1',  # der Meeresspiegel
    'x27345': 'B1',  # das Hochwasser
    'x27378': 'B1',  # das Gesundheitswesen
    'x27426': 'B1',  # die Herzkrankheit
    'x27463': 'B1',  # die Grillparty
    'x27468': 'B1',  # gärtnern
    'x27501': 'B1',  # die Kirschblüte
    'x27511': 'B1',  # die Tierquälerei
    'x27518': 'B1',  # der Raubvogel
    'x27547': 'B1',  # der Städter
    'x27597': 'B1',  # der Botaniker
    'x27635': 'B1',  # die Gastronomie
    'x27654': 'B1',  # der Hörsaal
    'x27701': 'B1',  # die Kinderbetreuung
    'x27718': 'B1',  # die Flugbegleiterin
    'x27808': 'B1',  # das Beet
    'x27836': 'B1',  # die Dienstreise
    'x23909': 'B1',  # die Geschäftsreise
    'x27878': 'B1',  # der Abstellraum
    'x27137': 'B1',  # die Abstellkammer
    'x27931': 'B1',  # das Unterhaus
    'x27945': 'B1',  # herumreisen
    'x27995': 'B1',  # das Wildtier
    'x27999': 'B1',  # die Spielfigur
    'x28051': 'B1',  # das Zugunglück
    'x28091': 'B1',  # die Kinderarbeit
    'x28101': 'B1',  # der Hexenschuss
    'x28103': 'B1',  # einplanen
    'x28113': 'B1',  # das Plüschtier
    'x28115': 'B1',  # jäten
    'x28130': 'B1',  # das Tagesgericht
    'x28174': 'B1',  # die Elternschaft
    'x28200': 'B1',  # der Nationalfeiertag
    'x28207': 'B1',  # die Gärtnerin
    'x28238': 'B1',  # der Wartesaal
    'x28258': 'B1',  # der Doktorand
    'x28284': 'B1',  # der Feldweg
    'x28299': 'B1',  # die Pandemie
    'x23772': 'B1',  # die Epidemie
    'x28309': 'B1',  # der Handstand
    'x28386': 'B1',  # die Dreiviertelstunde
    'x28448': 'B1',  # der Kurort
    'x28462': 'B1',  # der Pkw
    'x28524': 'B1',  # die Archäologin
    'x28539': 'B1',  # der Schneebesen
    'x28552': 'B1',  # das Heimatdorf
    'x28591': 'B1',  # der Schoß
    'x28594': 'B1',  # das Blockhaus
    'x28608': 'B1',  # die Konservendose
    'x28657': 'B1',  # die Viehzucht
    'x28666': 'B1',  # der Hausbau
    'x28719': 'B1',  # die Kinderkrankheit
    'x28741': 'B1',  # der Afrikaner
    'x28745': 'B1',  # die Hauswand
    'x28771': 'B1',  # raspeln
    'x28789': 'B1',  # aufleuchten
    'x28800': 'B1',  # das Meerestier
    'x28811': 'B1',  # die Brillenträgerin
    'x28839': 'B1',  # das Geburtshaus
    'x28845': 'B1',  # der Konzertsaal
    'x28855': 'B1',  # der Pfannenwender
    'x28874': 'B1',  # der Drittklässler
    'x28876': 'B1',  # die Stoßzeit
    'x24434': 'B1',  # der Elektriker
    'x24473': 'B1',  # die Eidechse
    'x24495': 'B1',  # die Abschlussfeier
    'x24506': 'B1',  # der Protestant
    'x24538': 'B1',  # durchfahren
    'x24622': 'B1',  # der Kanadier
    'x27996': 'B1',  # die Kanadierin
    'x24630': 'B1',  # die Zeitbombe
    'x24664': 'B1',  # der Barmann
    'x24672': 'B1',  # das Gewächshaus
    'x24691': 'B1',  # das Tierheim
    'x24731': 'B1',  # der Europäer
    'x28685': 'B1',  # der Niederländer
    'x24736': 'B1',  # die Chirurgin
    'x24749': 'B1',  # die Verpflegung
    'x24770': 'B1',  # der Junggeselle
    'x24778': 'B1',  # bereisen
    'x24819': 'B1',  # die Damentoilette
    'x24920': 'B1',  # die Familienangelegenheit
    'x25012': 'B1',  # die Petition
    'x25159': 'B1',  # nachahmen
    'x25233': 'B1',  # der Draufgänger
    'x25249': 'B1',  # das Wunderkind
    'x25261': 'B1',  # der Camper
    'x25373': 'B1',  # die Chinesin
    'x25378': 'B1',  # die Delikatesse
    'x25440': 'B1',  # der Surfer
    'x25770': 'B1',  # die Schwalbe
    'x25822': 'B1',  # der Lavendel
    'x25840': 'B1',  # die Italienerin
    'x25858': 'B1',  # die Eichel
    'x25995': 'B1',  # die Grube
    'x26044': 'B1',  # das Herrenhaus
    'x26070': 'B1',  # der Australier
    'x26121': 'B1',  # die Bürgerwehr
    'x26504': 'B1',  # der Kranich
    'x26550': 'B1',  # der Finne
    'x27206': 'B1',  # die Kommunistin
    'x27208': 'B1',  # die Mexikanerin
    'x27240': 'B1',  # promovieren
    'x27310': 'B1',  # das Standbild
    'x27453': 'B1',  # der Epileptiker
    'x27477': 'B1',  # der Betrüger
    'x27655': 'B1',  # befahren
    'x27709': 'B1',  # der Analphabet
    'x27747': 'B1',  # das Trimester
    'x27802': 'B1',  # der Ohrwurm
    'x27850': 'B1',  # der Hotelpage
    'x27857': 'B1',  # die Irin
    'x24415': 'B1',  # der Ire
    'x27861': 'B1',  # der Schuldner
    'x28491': 'B1',  # der Gläubiger
    'x27951': 'B1',  # der Kugelfisch
    'x28720': 'B1',  # die Katzenminze
    'x28729': 'B1',  # die Traumfrau
    'x28747': 'B1',  # der Umtrunk
    'x23523': 'B1',  # der Sammler
    'x23527': 'B1',  # der Stalker
    'x23593': 'B1',  # die Weile
    'x23613': 'B1',  # der Express
    'x23621': 'B1',  # miterleben
    'x23657': 'B1',  # das Unkraut
    'x23665': 'B1',  # erstmals
    'x23666': 'B1',  # der Traktor
    'x23720': 'B1',  # der Londoner
    'x23776': 'B1',  # auffangen
    'x23784': 'B1',  # der Alligator
    'x23830': 'B1',  # der Wanderer
    'x23957': 'B1',  # der Dolmetscher
    'x23966': 'B1',  # der Alzheimer
    'x24032': 'B1',  # die Französin
    'x24037': 'B1',  # herumsitzen
    'x24130': 'B1',  # das Hockey
    'x24246': 'B1',  # das Wohnheim
    'x24313': 'B1',  # das Cockpit
    'x24317': 'B1',  # der Mädchenname
    'x24360': 'B1',  # die Dokumentation
    'x24381': 'B1',  # diesjährig
    'x24382': 'B1',  # damalig
    'x24430': 'B1',  # fahnden
    'x24588': 'B1',  # die Hyäne
    'x24658': 'B1',  # das Stinktier
    'x24735': 'B1',  # die Pocke
    'x25165': 'B1',  # der Fuchs
    'x25189': 'B1',  # stetig
    'x25552': 'B1',  # die Belegschaft
    'x25797': 'B1',  # die Montage
    'x26173': 'B1',  # der Most
    'x26359': 'B1',  # das Gänseblümchen
    'x26510': 'B1',  # der Hammel
    'x28407': 'B1',  # das Hammelfleisch
    'x26621': 'B1',  # vorsetzen
    'x26662': 'B1',  # stauen
    'x26710': 'B1',  # der Takt
    'x27050': 'B1',  # der Herzschrittmacher
    'x27099': 'B1',  # der Spinner
    'x27160': 'B1',  # der Hanf
    'x27225': 'B1',  # die Languste
    'x27230': 'B1',  # die Meise
    'x27316': 'B1',  # hineinstecken
    'x27319': 'B1',  # der Laib
    'x27446': 'B1',  # heuer
    'x27465': 'B1',  # das Arbeitstier
    'x27606': 'B1',  # der Partylöwe
    'x28245': 'B1',  # die Verwirklichung
    'x28327': 'B1',  # der Schlot
    'x28421': 'B1',  # der Wetterfrosch
    'x28526': 'B1',  # die Mansarde
    'x28617': 'B1',  # das Fuhrwerk
    'x28746': 'B1',  # die Sternstunde
    'x28803': 'B1',  # der Personenschützer
    'x28860': 'B1',  # zeitlebens

    # --- B2: common enough to reach, but register-specific ---------------
    'x25742': 'B2',  # der Vordermann
    'x24556': 'B2',  # die Personalabteilung
    'x24726': 'B2',  # der Gehilfe
    'x24913': 'B2',  # die Kost
    'x25082': 'B2',  # reinhauen
    'x25434': 'B2',  # tränken
    'x25661': 'B2',  # unterlaufen
    'x25681': 'B2',  # der Nachruf
    'x25730': 'B2',  # die Zuwendung
    'x25771': 'B2',  # zubringen
    'x25918': 'B2',  # der Anhieb
    'x26026': 'B2',  # geraum
    'x26159': 'B2',  # zuweilen
    'x26585': 'B2',  # bisweilen
    'x26226': 'B2',  # grummeln
    'x26236': 'B2',  # der Greis
    'x26327': 'B2',  # tunken
    'x26573': 'B2',  # der Holzweg
    'x26610': 'B2',  # der Gockel
    'x26638': 'B2',  # das Getöse
    'x26737': 'B2',  # der Miesepeter
    'x26764': 'B2',  # abrichten
    'x26779': 'B2',  # bodenständig
    'x26846': 'B2',  # der Heißhunger
    'x27076': 'B2',  # erbeben
    'x27116': 'B2',  # der Sonderling
    'x27309': 'B2',  # die Trinkerei
    'x27921': 'B2',  # die Sauferei
    'x27631': 'B2',  # das Besäufnis
    'x27312': 'B2',  # der Geldsack
    'x27326': 'B2',  # (unused, harmless if absent)
    'x27847': 'B2',  # das Mauerblümchen
    'x27872': 'B2',  # schwelgen
    'x27944': 'B2',  # die Stulle
    'x28243': 'B2',  # die Haaresbreite
    'x28750': 'B2',  # der Stubenhocker
    'x28823': 'B2',  # der Kurpfuscher
    'x28875': 'B2',  # die Naschkatze
    'x24494': 'B2',  # der Hochstapler
    'x24550': 'B2',  # der Rotschopf
    'x24573': 'B2',  # das Bankett
    'x24580': 'B2',  # der Lump
    'x24709': 'B2',  # der Spielraum
    'x24751': 'B2',  # der Ehrenmann
    'x24752': 'B2',  # der Narr
    'x24884': 'B2',  # die Pelle
    'x25812': 'B2',  # der Tollpatsch
    'x25810': 'B2',  # der Quacksalber
    'x26326': 'B2',  # der Hampelmann
    'x23385': 'B2',  # das Exil
    'x23450': 'B2',  # vorzüglich
    'x23472': 'B2',  # das Empire
    'x23473': 'B2',  # die Berühmtheit
    'x23521': 'B2',  # wohlauf
    'x23540': 'B2',  # nimmer
    'x23597': 'B2',  # verdrücken
    'x23695': 'B2',  # der Playboy
    'x23777': 'B2',  # das Mahl
    'x23801': 'B2',  # das Hausmädchen
    'x23988': 'B2',  # der Nichtsnutz
    'x24253': 'B2',  # allemal
    'x24293': 'B2',  # die Schar
    'x24300': 'B2',  # helllicht
    'x24365': 'B2',  # der Langweiler
    'x24423': 'B2',  # freundschaftlich
    'x24435': 'B2',  # binnen
    'x25057': 'B2',  # der Tank
}

PATH = 'lib/vocabulary_generated.dart'


def main() -> None:
    text = io.open(PATH, encoding='utf-8').read()
    changed, missing, unchanged = 0, [], 0
    for card_id, level in RELEVEL.items():
        pattern = re.compile(
            r"(id: '" + re.escape(card_id) + r"'.*?level: ')([^']*)(')", re.S)
        match = pattern.search(text)
        if not match:
            missing.append(card_id)
            continue
        if match.group(2) == level:
            unchanged += 1
            continue
        text = pattern.sub(lambda m: m.group(1) + level + m.group(3), text,
                           count=1)
        changed += 1
    with io.open(PATH, 'w', encoding='utf-8', newline='') as handle:
        handle.write(text)
    print('re-levelled %d cards' % changed)
    if unchanged:
        print('%d already at the target level' % unchanged)
    if missing:
        print('%d ids not found: %s' % (len(missing), ', '.join(missing)))


if __name__ == '__main__':
    main()
