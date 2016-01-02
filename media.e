deferred class MEDIA

feature{}
	titre: STRING
	nombre_exemplaires: INTEGER
	lst_reservations : ARRAY[RESERVATION]
	lst_emprunts :  ARRAY[EMPRUNT]

feature {ANY}
	make is 
		do
			titre:= ""
			nombre_exemplaires:= 1
			create lst_reservations.with_capacity(1,0)
			create lst_emprunts.with_capacity(1,0)
		end
		
	to_string : STRING is
		--do
			deferred
			--Result:= "MEDIA : {titre : "+titre+", nombre_exemplaires : "+nombre_exemplaires.to_string+"}"
		end
	
	-- getter et setter
	set_titre (t: STRING) is
		do
			titre.copy(t)
		end

	set_nombre_exemplaires (nb : INTEGER) is
		do
			nombre_exemplaires := nb
		end
	
	ajouter_emprunt (emp: EMPRUNT) : STRING is
		local
			trouver : BOOLEAN
			i : INTEGER
			ajouter : STRING
		do
			trouver := False
			-- On parcourt la liste des emprunts pour vérifier que l'utilisateur n'a pas déjà fait un emprunt
			from i:=0
			until i = lst_emprunts.count
			loop
				-- test sur l'identifiant
				if lst_emprunts.item(i).get_user.get_identifiant = emp.get_user.get_identifiant then
					trouver := True
					ajouter := "FAIT"
				end
				i := i+1
			end
			-- S'il n'exite pas, on vérifie que l'emprunt concerne l'instance du média et qu'il y a des exemplaires disponibles
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				if emp.get_livre /= Void then
					if emp.get_livre.get_titre = titre and lst_emprunts.count < nombre_exemplaires then
						ajouter := "OUI"
						lst_emprunts.add_last(emp)
					else
						ajouter := "NON"
					end
				else
					if emp.get_dvd.get_titre = titre and lst_emprunts.count < nombre_exemplaires then
						ajouter := "OUI"						
						lst_emprunts.add_last(emp)
					else
						ajouter := "NON"
					end
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
			-- On parcourt la liste des réservation pour vérifier que l'utilisateur n'a pas déjà fait une résevation
			from i:=0
			until i = lst_reservations.count
			loop
				-- test sur l'identifiant
				if lst_reservations.item(i).get_user.get_identifiant = res.get_user.get_identifiant then
					trouver := True
				end
				i := i+1
			end
			-- S'il n'exite pas, on vérifie que la réservation concerne l'instance du média
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				if res.get_livre /= Void then
					ajouter := False
					if res.get_livre.get_titre = titre then
						ajouter :=True
						res.set_priorite(lst_reservations.count+1)
						lst_reservations.add_last(res)
					end
				else
					ajouter := False
					if res.get_dvd.get_titre = titre then
						ajouter := True						
						res.set_priorite(lst_reservations.count+1)
						lst_reservations.add_last(res)
					end
				end					
			else
				ajouter := False
			end
			Result := ajouter
		end
		
	get_titre : STRING is
		do
			Result:= titre
		end
		
	get_nombre_exemplaires : INTEGER is
		do
			Result:= nombre_exemplaires
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

	
