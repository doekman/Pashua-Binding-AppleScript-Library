Pashua Binding AppleScript Library
==================================

To enable logging: `defaults write com.zanstra.ASPashua do_log '1'`

versie 1
--------
Basisversie die doen wat het doen moet:

* `display_dialog_with_string` en `display_dialog_with_file`: geeft een record terug of een exception als er op annuleren gedrukt wordt
  - of één method `display pashua dialog` die zowel string als file accepteert?
  - private: locate pashua app
  - converteer "[return]" automatically?
* logging (optioneel met defaults write)
* voorbeelden
* build script om de library te maken
  - optioneel include Pashua.app
  - plist
  - sdef maken.
  - icoon maken?

testen

versie 2
--------
Meer "native" maken:

* `display_multi_dialog` in analogie met de standard `display dialog` (sdef nodig, ivm optionele parameters?)
  - Als extra optie een type meegeven (text, date, datetime, boolean, openbrowser)
* kijken of we een applicatie kunnen maken die *.pashua bestanden kan openen met Pashua
* eventuele handige opties:
  - automatisch `autosavekey` aanmaken
* voorbeeld maken om wachtwoord automatisch op te slaan in keychain


versie 3
--------

Eventueel een AppleScript-achtige syntax bedenken om dialogen te maken (zit hier iemand op te wachten?)


Feature requests voor Pashua
----------------------------

* Localizen voor NL (voorstellen)
* Number input (voor huisnummers)
* Detecteren als er op cancel gedrukt is (bijv. door een exit-code)

bugs:

* die dubbele focus als een formulier geopend wordt
* documentatie: `default` wordt bij combobox niet genoemd

