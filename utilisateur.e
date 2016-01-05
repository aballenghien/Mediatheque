class UTILISATEUR

creation{ANY}
	make

feature{}
	nom: STRING
	prenom: STRING
	identifiant: STRING
	admin: BOOLEAN
	lst_emprunts : ARRAY[EMPRUNT]
	lst_reservations : ARRAY[RESERVATION]

feature{ANY}
	make is
		do
			nom := ""
			prenom := ""
			identifiant := ""
			admin := False
			create lst_reservations.with_capacity(1,0)
			create lst_emprunts.with_capacity(1,0)
		end

	to_string : STRING is
		local
			retour : STRING
		do
			retour := ""
			retour.copy("UTILISATEUR :  %N %T Nom : "+nom+" %N %T Prénom : "+prenom+" %N %T Identifiant : "+identifiant)
			if is_admin then
				retour.append("%N %T Administrateur : Oui")
			end
			retour.append("%N")
			Result:= retour
		end

	-- getter et setter
	set_nom (n: STRING) is
		do
			nom.copy(n)
		end
	
	set_prenom (p: STRING) is
		do
			prenom.copy(p)
		end
	
	set_identifiant (id: STRING) is
		do
			identifiant.copy(id)
		end	

	set_admin(ad: BOOLEAN) is
		do
			admin := ad
		end
		
	ajouter_emprunt (emp : EMPRUNT) :  BOOLEAN is
		local
			trouver : BOOLEAN
			i : INTEGER
			ajouter : BOOLEAN
		do
			trouver := False
			-- On parcourt la liste des emprunts pour vérifier que l'utilisateur n'a pas déjà cett emprunt
			from i:=0
			until i = lst_emprunts.count
			loop
				-- test sur le titre
				if emp.get_dvd /= Void and lst_emprunts.item(i).get_dvd /= Void then
					if lst_emprunts.item(i).get_dvd.get_titre = emp.get_dvd.get_titre then
						trouver := True
					end
				else
					if emp.get_livre /= Void and lst_emprunts.item(i).get_livre /= Void then
						if lst_emprunts.item(i).get_livre.get_titre = emp.get_livre.get_titre then
							trouver := True
						end
					end
				end
				i := i+1
			end
			-- S'il n'exite pas, on vérifie que l'emprunt concerne l'utilisateur et que l'utilisateur n'a pas dépasser son nombre d'emprunts
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				ajouter := False
				if emp.get_user.get_identifiant = identifiant and lst_emprunts.count < 3 then
					ajouter :=True
					lst_emprunts.add_last(emp)
				end	
			end
			Result := ajouter
		end
		
	ajouter_reservation (res: RESERVATION) :  BOOLEAN is
		local
			trouver : BOOLEAN
			i : INTEGER
			ajouter : BOOLEAN
		do
			trouver := False
			-- On parcourt la liste des réservation pour vérifier que l'utilisateur n'a pas déjà cette résevation
			from i:=0
			until i = lst_reservations.count
			loop
				-- test sur le titre
				if res.get_dvd /= Void and lst_reservations.item(i).get_dvd /= Void then
					if lst_reservations.item(i).get_dvd.get_titre = res.get_dvd.get_titre then
						trouver := True
					end
				else
					if res.get_livre /= Void and lst_reservations.item(i).get_livre /= Void then
						if lst_reservations.item(i).get_livre.get_titre = res.get_livre.get_titre then
							trouver := True
						end
					end
				end
				i := i+1
			end
			-- S'il n'exite pas, on vérifie que l'emprunt concerne l'utilisateur et que l'utilisateur n'a pas dépasser sont nombre d'emprunt
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				ajouter := False
				if res.get_user.get_identifiant = identifiant and lst_reservations.count < 3 then
					ajouter :=True
					lst_reservations.add_last(res)
				end	
			end
			Result := ajouter
		end
	
	get_nom : STRING is
		do
			Result := nom
		end
	
	get_prenom : STRING is
		do
			Result := prenom
		end

	get_identifiant : STRING is
		do
			Result := identifiant
		end
		
	is_admin : BOOLEAN is
		do
			Result := admin
		end
		
	get_lst_reservations : ARRAY[RESERVATION] is
		do
			Result := lst_reservations
		end
		
	get_lst_emprunts : ARRAY[EMPRUNT] is
		do 
			Result := lst_emprunts
		end
end

	
