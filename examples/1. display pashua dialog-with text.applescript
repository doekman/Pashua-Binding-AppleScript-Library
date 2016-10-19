(* The following line is needed to use ASPashua *)
use script "ASPashua"
(* When you don't have any "use" statements, the following is incluced automatically. *)
(* When including ASPashua, you need to uncomment this when using things like "display alert" *)
use scripting additions

(* The form definition. See the documentation: http://www.bluem.net/pashua-docs-latest.html *)
set config_text to "# Pashua dialog config
name.type = textfield
name.label = First & Last Name
email.type = textfield
email.label = Email Address
dob.type = date
dob.label = Date of Birth
dob.textual = 1
agree.type = checkbox
agree.label = Do You Agree Evading Your Privacy?
cb.type = cancelbutton
db.type = defaultbutton"

display pashua dialog config_text

