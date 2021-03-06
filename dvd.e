class DVD inherit
	MEDIA
	rename make as make_media
	end

creation{ANY}
	make

feature{}
	annee: INTEGER
	type: STRING
	lst_acteurs: ARRAY[ACTEUR]
	lst_realisateurs: ARRAY[REALISATEUR]

feature {ANY}
	make is
		do
			make_media
			annee := 0	
			type := ""		
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
		end
		
	-- Fonction permettant d'ajouter un acteur à la liste des acteurs des DVD
	ajouter_acteur (a: ACTEUR) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			-- On parcourt la liste des acteurs pour vérifier qu'il n'existe pas déjà
			from i:=0
			until i = lst_acteurs.count
			loop
				-- test sur le nom et le prénom pour vérifier si l'acteur existe
				if lst_acteurs.item(i).get_prenom.is_equal(a.get_prenom) 
					and lst_acteurs.item(i).get_nom.is_equal(a.get_nom) then
					trouver := True
				end
				i := i+1
			end			
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				lst_acteurs.add_last(a)
			end
		end
		
	-- Fonction permettant d'ajouter un réalisateur à la liste des réalisateurs des DVD
	ajouter_realisateur (r: REALISATEUR) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			-- On parcourt la liste des réalisateurs pour vérifier qu'il n'existe pas déjà
			from i:=0
			until i = lst_realisateurs.count
			loop
				-- test sur le nom et le prénom pour vérifier si le réalisation existe
				if lst_realisateurs.item(i).get_prenom.is_equal(r.get_prenom) 
					and lst_realisateurs.item(i).get_nom.is_equal(r.get_nom) then
					trouver := True
				end
				i := i+1
			end
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				lst_realisateurs.add_last(r)
			end
		end
		
	to_string : STRING is
		do
			Result := "DVD : "+titre
		end
		
	-- Getter et setter
	set_annee(a: INTEGER) is
		do
			annee := a
		end
		
	set_type(t: STRING) is
		do
			type.copy(t)
		end
	
	get_annee : INTEGER is
		do
			Result:= annee
		end
		
	get_type : STRING is
		do
			Result:= type
		end
	
	get_lst_acteurs : ARRAY[ACTEUR] is
		do
			Result := lst_acteurs
		end
		
	get_lst_realisateurs : ARRAY[REALISATEUR] is
		do
			Result := lst_realisateurs
		end
end
