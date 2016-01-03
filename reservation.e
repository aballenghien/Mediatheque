class RESERVATION

creation{ANY}
	make

feature{}
	user: UTILISATEUR
	livre: LIVRE
	dvd : DVD
	priorite : INTEGER

feature{ANY}
	make is
		do
			create user.make
		end
	
	afficher_contenu_reservation : STRING is
		do
			if livre/= Void then
				Result := livre.to_string
			else 
				Result := dvd.to_string
			end
		end
	
	format_enregistrement : STRING is
		local
			rst : STRING
		do
			rst := ""
			rst.copy("Utilisateur<"+user.get_identifiant+"> ; ")
			if livre /= Void then
				rst.append("LIVRE<"+livre.get_titre+"> ; ")
			else
				rst.append("DVD<"+dvd.get_titre+"> ; ")
			end
			rst.append("Priorite<"+priorite.to_string+">")
			Result := rst
		end
		
		
	to_string : STRING is
		local
			rst: STRING
		do
			rst := ""
			rst.copy("UTILISATEUR : "+user.get_identifiant)
			rst.copy(afficher_contenu_reservation)
			Result := rst
		end
		
	get_user : UTILISATEUR is
		do
			Result := user
		end
		
	get_livre : LIVRE is
		do
			Result := livre
		end
		
	get_dvd : DVD is
		do
			Result := dvd
		end
	get_priorite: INTEGER is
		do
			Result := priorite
		end
		
	set_user (u: UTILISATEUR) is
		do
			user := u
		end
		
	set_livre (l: LIVRE) is
		do
			livre := l
		end
		
	set_dvd (d: DVD) is
		do
			dvd := d
		end
		
	set_priorite (p: INTEGER) is
		do 
			priorite := p
		end
	

end
