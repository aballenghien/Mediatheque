class DVD inherit
	MEDIA
	rename make as make_media
	redefine to_string
	end

creation{ANY}
	make

feature{}
	annee: INTEGER
	lst_acteurs: ARRAY[ACTEUR]
	lst_realisateurs: ARRAY[REALISATEUR]

feature {ANY}
	make is
		do
			make_media
			annee := 0			
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
		end
		
	set_annee(a: INTEGER) is
		do
			annee := a
		end
	
	get_annee : INTEGER is
		do
			Result:= annee
		end
	
	get_lst_acteurs : ARRAY[ACTEUR] is
		do
			Result := lst_acteurs
		end
		
	get_lst_realisateurs : ARRAY[REALISATEUR] is
		do
			Result := lst_realisateurs
		end
	
	ajouter_acteur (a: ACTEUR) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			from i:=0
			until i = lst_acteurs.count
			loop
				if lst_acteurs.item(i).get_prenom.is_equal(a.get_prenom) then
					trouver := True
				end
				i := i+1
			end
			if not trouver then
				lst_acteurs.add_last(a)
			end
		end
		
	ajouter_realisateur (r: REALISATEUR) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			from i:=0
			until i = lst_realisateurs.count
			loop
				if lst_realisateurs.item(i).get_prenom.is_equal(r.get_prenom) then
					trouver := True
				end
				i := i+1
			end
			if not trouver then
				lst_realisateurs.add_last(r)
			end
		end
		
	to_string : STRING is
		local
			rst : STRING
			i : INTEGER
		do
			rst := ""
			rst.append("DVD:{ titre:"+titre+" , nombre_exemplaire:"+nombre_exemplaires.to_string+" annee:"+annee.to_string+", lst_acteurs:")
			from i:= 0
			until i = lst_acteurs.count
			loop
				rst.append(lst_acteurs.item(i).to_string)
				i := i+1
			end
			rst.append(", lst_realisateurs:")
			from i:= 0
			until i = lst_realisateurs.count
			loop
				rst.append(lst_realisateurs.item(i).to_string)
				i := i+1
			end
			rst.append("}")
			Result:= rst
		end

end
