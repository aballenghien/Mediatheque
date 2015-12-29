class REALISATEUR inherit
	PERSONNE
	rename make as make_personne
	end

creation{ANY}
	make

feature{}
	lst_films: ARRAY[DVD]

feature {ANY}
	make is
		do
			make_personne
			create lst_films.with_capacity(1,0)
		end
		
	-- Fonction permettant d'ajouter un film à la liste des films du réalisateur
	ajouter_film (un_film: DVD) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			-- On parcourt la liste des films pour vérifier qu'il n'existe pas déjà
			from i:=0
			until i = lst_films.count
			loop
				-- test sur le titre pour vérifier que le film existe
				if lst_films.item(i).get_titre.is_equal(un_film.get_titre) then
					trouver := True
				end
				i := i+1
			end
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				lst_films.add_last(un_film)
			end
		end
		
	to_string : STRING is
		local
			rst: STRING
			i : INTEGER
		do
			rst := ""
			rst.append("REALISATEUR :  %N %T Nom : "+nom+" %N %T Prénom :"+prenom+" %N %T Liste des films associés : ")
			from i:=0
			until i = lst_films.count
			loop
				rst.append(" %N %T %T - "+lst_films.item(i).get_titre)
				i:= i+1
			end
			Result := rst
		end
		
	-- getter
	get_lst_films : ARRAY[DVD] is
		do
			Result := lst_films
		end
end
