class AUTEUR inherit
	PERSONNE
	rename make as make_personne
	end

creation{ANY}
	make

feature{}
	lst_livres: ARRAY[LIVRE]

feature {ANY}
	make is
		do
			make_personne
			create lst_livres.with_capacity(1,0)
		end
	
	-- Fonction permettant d'ajouter un livre à la liste des livres de l'auteur
	ajouter_livre (un_livre: LIVRE) is
		local
			trouver : BOOLEAN
			i : INTEGER
		do
			trouver := False
			-- On parcourt la liste des livres pour vérifier qu'il n'existe pas déjà
			from i:=0
			until i = lst_livres.count
			loop
				-- test sur le titre pour vérifier que le livre existe
				if lst_livres.item(i).get_titre.is_equal(un_livre.get_titre) then
					trouver := True
				end
				i := i+1
			end
			-- S'il n'exite pas, on l'ajoute à la fin de la liste
			if not trouver then
				lst_livres.add_last(un_livre)
			end
		end
		
	-- Fonction permettant d'afficher les informations d'un auteur
	to_string : STRING is
		local
			rst: STRING
			i : INTEGER
		do
			rst := ""
			rst.append("AUTEUR : %N %T Nom : "+nom+" %N %T Prénom :"+prenom+" %N %T Liste des livres associés :")
			from i:=0
			until i = lst_livres.count
			loop
				rst.append(" %N %T %T -"+lst_livres.item(i).get_titre)
				i:= i+1
			end
			Result := rst
		end
		
	-- Getter
	get_lst_livres : ARRAY[LIVRE] is
		do
			Result := lst_livres
		end
end
