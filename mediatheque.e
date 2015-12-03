class MEDIATHEQUE

creation{ANY}
	make

feature{}
	lst_users: ARRAY[UTILISATEUR] -- liste des utilisateurs
  	lst_medias: ARRAY[MEDIA] -- liste des medias
 	lst_acteurs: ARRAY[ACTEUR] --liste des acteurs
 	lst_realisateurs: ARRAY[REALISATEUR] --liste des réalisateurs
  	lst_auteurs: ARRAY[AUTEUR] -- liste des auteurs
  	lst_livres: ARRAY[LIVRE]
  	lst_dvd : ARRAY[DVD]

feature{ANY}
	make is
		do
			create lst_users.with_capacity(1, 0)
			create lst_medias.with_capacity(1,0)
			create lst_auteurs.with_capacity(1,0)
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
			create lst_livres.with_capacity(1,0)
			create lst_dvd.with_capacity(1,0)
			remplir_lst_users
		--	afficher_tableau_user
			remplir_lst_medias
		--	afficher_tableau_media
			remplir_lst_auteurs_realisateurs_acteurs
			afficher_tableau_auteurs
			afficher_tableau_acteurs
			afficher_tableau_realisateurs
		end

--récupère tous les utilisateurs dans le fichier
	remplir_lst_users is
		local
			ligne: STRING -- ligne du fichier utilisateur
			fichier: TEXT_FILE_READ -- Fichier utilisateur ouvert en lecture
			i, index_start, index_end: INTEGER
			nom, prenom, id, admin: STRING -- Attributs utilisateur
			user: UTILISATEUR
			ligne_tab : ARRAY[STRING]
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			nom := ""
			prenom := ""
			id := ""
			admin := ""			
			
			-- Création et ouverture du fichier
			create fichier.make
			fichier.connect_to("utilisateurs.txt")
			
			-- lecture du fichier
			from 
			until fichier.end_of_input 
			loop					
				-- Creation de l'utilisateur
				create user.make
				-- Initialisation du contenant dans chaque case, le texte 
				-- contenu entre les points virgules de "ligne"
				create ligne_tab.with_capacity(1,0)

				ligne := ""
				index_end:= 1
				index_start:=1
				
				-- Lecture d'une ligne
				fichier.read_line_in(ligne)
				
				if ligne.count > 0 then
					
					-- parcours de la ligne, séparation au niveau des 
					-- points virgules et remplissage du tableau
					from  
					until index_end = 0
					loop
						index_end := ligne.index_of(';',index_start)
						if index_end > 0 then
							ligne_tab.add_last(ligne.substring(index_start, index_end-1))
							index_start := index_end+1
						else
							if index_end = 0 then
								ligne_tab.add_last(ligne.substring(index_start, ligne.count))
							end
						end
					end

					--parcours du tableau contenant la ligne fractionnée
					from i :=0
					until i = ligne_tab.count
					loop
						-- si la case correspond au nom, attribuer le nom à l'utilisateur
						if ligne_tab.item(i).has_substring("Nom") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end

						-- si la case correspond au prénom, attribuer le 
						-- prénom à l'utilisateur
						if ligne_tab.item(i).has_substring("Prenom") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end

						-- si la case correspond à l'identifiant, attribuer 
						-- l'identifiant à l'utilisateur
						if ligne_tab.item(i).has_substring("Identifiant") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							user.set_identifiant(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end

						-- si la case indique que l'utilisateur est un 
						-- administrateur, l'attribut admin de l'utilisateur est mis à vrai
						if ligne_tab.item(i).has_substring("Admin") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							admin.copy(ligne_tab.item(i).substring(index_start+1, index_end-1))
							if admin.is_equal("OUI") then
								user.set_admin(True)
							else
								user.set_admin(False)
							end
						end
						i := i + 1
					end
					


					-- Ajout de l'utilisateur dans le tableau
					lst_users.add_last(user)
				end
							
			end
		end
	--récupère tous les médias du fichier	
	remplir_lst_medias is
		local
			ligne: STRING -- ligne du fichier utilisateur
			fichier: TEXT_FILE_READ -- Fichier media ouvert en lecture
			i, index_start, index_end: INTEGER
			titre: STRING 
			livre: LIVRE
			dvd: DVD
			ligne_tab : ARRAY[STRING]
			is_livre: BOOLEAN
			auteur: AUTEUR
			realisateur: REALISATEUR
			acteur: ACTEUR
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""	
			is_livre := False	
			
			-- Création et ouverture du fichier
			create fichier.make
			fichier.connect_to("medias.txt")
			
			-- lecture du fichier
			from 
			until fichier.end_of_input 
			loop	
				-- Initialisation du contenant dans chaque case, le texte 
				-- contenu entre les points virgules de "ligne"
				create ligne_tab.with_capacity(1,0)

				ligne := ""
				index_end:= 1
				index_start:=1
				
				-- Lecture d'une ligne
				fichier.read_line_in(ligne)
				
				if ligne.count > 0 then
					
					-- parcours de la ligne, séparation au niveau des 
					-- points virgules et remplissage du tableau
					from  
					until index_end = 0
					loop
						index_end := ligne.index_of(';',index_start)
						if index_end > 0 then
							ligne_tab.add_last(ligne.substring(index_start, index_end-1))
							index_start := index_end+1
						else
							if index_end = 0 then
								ligne_tab.add_last(ligne.substring(index_start, ligne.count))
							end
						end
					end

					--parcours du tableau contenant la ligne fractionnée
					from i :=0
					until i = ligne_tab.count
					loop
						-- si la case correspond au type livre, créer un livre
						if ligne_tab.item(i).has_substring("Livre") then
							is_livre := True
							create livre.make
						end
						
						-- si la case correspond au type dvd, créer un dvd
						if ligne_tab.item(i).has_substring("DVD") then
							is_livre := False
							create dvd.make
						end
						

						-- si la case correspond au titre, attribuer le 
						-- titre au media
						if ligne_tab.item(i).has_substring("Titre") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							if is_livre then
								livre.set_titre(ligne_tab.item(i).substring(index_start+1, index_end-1))
							else
								dvd.set_titre(ligne_tab.item(i).substring(index_start+1, index_end-1))
							end
						end

						-- si la case correspond à nombre d'exemplaire, attribuer 
						-- le nombre d'exemplaires au média
						if ligne_tab.item(i).has_substring("Nombre") then
							index_start := ligne_tab.item(i).index_of('<', 1)					
							index_end := ligne_tab.item(i).index_of('>', 1)
							if is_livre then
								livre.set_nombre_exemplaires((ligne_tab.item(i).substring(index_start+1, index_end-1)).to_integer)
							else
								dvd.set_nombre_exemplaires((ligne_tab.item(i).substring(index_start+1, index_end-1)).to_integer)
							end
						end

						--si la case indique un auteur, on assigne l'auteur au livre
						if ligne_tab.item(i).has_substring("Auteur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create auteur.make
							auteur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						 --	index_start := ligne_tab.item(i).index_of(' ', 1)
						 --	index_end := ligne_tab.item(i).index_of('>', 1)
						 --	auteur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							livre.set_auteur(auteur)
							
						end
						
						--si la case indique un acteur, on ajoute l'acteur à la liste
						if ligne_tab.item(i).has_substring("Acteur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create acteur.make
							acteur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						-- 	index_start := ligne_tab.item(i).index_of('<', 1)
						-- 	index_end := ligne_tab.item(i).index_of(' ', 1)
						-- 	acteur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							dvd.ajouter_acteur(acteur)
						end
						
						--si la case indique un réalisateur, on ajoute le réalisateur à la liste
						if ligne_tab.item(i).has_substring("Realisateur") then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', 1)
							create realisateur.make
							realisateur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						--	index_start := ligne_tab.item(i).index_of(' ', 1)
						--	index_end := ligne_tab.item(i).index_of('>', 1)
						--	realisateur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))						
							dvd.ajouter_realisateur(realisateur)
						end
						i := i + 1
					end
					


					-- Ajout du média dans le tableau
					if is_livre then
						lst_medias.add_last(livre)
						lst_livres.add_last(livre)
					else 
						lst_medias.add_last(dvd)
						lst_dvd.add_last(dvd)
					end					
				end
							
			end
		end

	
		
	remplir_lst_auteurs_realisateurs_acteurs is
		local
			i: INTEGER
			un_dvd : DVD
			un_livre : LIVRE
		do
			from i:= 0
			until i = lst_livres.count
			loop
				un_livre := lst_livres.item(i)
				remplir_lst_auteurs(un_livre)
				i := i+1
			end
			from i:= 0
			until i = lst_dvd.count
			loop
				un_dvd := lst_dvd.item(i)
				remplir_lst_acteurs(un_dvd)
				remplir_lst_realisateurs(un_dvd)
				i := i+1
			end
		end
		
	remplir_lst_auteurs (un_livre: LIVRE) is
		local
			un_auteur : AUTEUR
			indice_trouver : INTEGER
		do
			un_auteur := un_livre.get_auteur
			if un_auteur /= Void then
				indice_trouver := verifier_lst_auteurs(un_auteur)
				if indice_trouver >=0 then
					lst_auteurs.item(indice_trouver).ajouter_livre(un_livre)
				else
					un_auteur.ajouter_livre(un_livre)
					lst_auteurs.add_last(un_auteur)
				end				
			end
		end
	remplir_lst_acteurs(un_dvd : DVD) is
		local
			i : INTEGER
			acteurs : ARRAY[ACTEUR]
			indice_trouver : INTEGER
		do
			acteurs := un_dvd.get_lst_acteurs
			from i:= 0
			until i = acteurs.count
			loop
				indice_trouver := verifier_lst_acteurs(acteurs.item(i))
				if indice_trouver >= 0 then
					lst_acteurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					acteurs.item(i).ajouter_film(un_dvd)
					lst_acteurs.add_last(acteurs.item(i))
				end
				i:= i+1
			end
		end
			
	remplir_lst_realisateurs(un_dvd : DVD) is
		local
			i : INTEGER
			realisateurs : ARRAY[REALISATEUR]
			indice_trouver : INTEGER
		do
			realisateurs := un_dvd.get_lst_realisateurs
			from i:= 0
			until i = realisateurs.count
			loop
				indice_trouver := verifier_lst_realisateurs(realisateurs.item(i))
				if indice_trouver >= 0 then
					lst_realisateurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					realisateurs.item(i).ajouter_film(un_dvd)
					lst_realisateurs.add_last(realisateurs.item(i))
				end
				i:= i+1
			end
		end
				
	verifier_lst_auteurs(un_auteur : AUTEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			from i := 0
			until i = lst_auteurs.count
			loop
				
				if un_auteur.get_prenom.is_equal(lst_auteurs.item(i).get_prenom) then
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end	
		
	verifier_lst_acteurs(un_acteur : ACTEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			from i := 0
			until i = lst_acteurs.count
			loop
				
				if un_acteur.get_prenom.is_equal(lst_acteurs.item(i).get_prenom) then
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end	
		
	verifier_lst_realisateurs(un_realisateur : REALISATEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			from i := 0
			until i = lst_realisateurs.count
			loop
				
				if un_realisateur.get_prenom.is_equal(lst_realisateurs.item(i).get_prenom) then
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end	
						
	afficher_tableau_user is
		local
			i :INTEGER
		do
			io.put_string("affichage des utilisateurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_users.count
			loop
				io.put_string(lst_users.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_media is
		local
			i :INTEGER
		do
			io.put_string("affichage des médias")
			io.put_string("%N")
			from i:= 0
			until i = lst_livres.count
			loop					
				io.put_string(lst_livres.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
			from i:= 0
			until i = lst_dvd.count
			loop					
				io.put_string(lst_dvd.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_auteurs is
		local
			i :INTEGER
		do
			io.put_string("affichage des auteurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_auteurs.count
			loop
				io.put_string(lst_auteurs.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_realisateurs is
		local
			i :INTEGER
		do
			io.put_string("affichage des réalisateurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_realisateurs.count
			loop
				io.put_string(lst_realisateurs.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_tableau_acteurs is
		local
			i :INTEGER
		do
			io.put_string("affichage des acteurs")
			io.put_string("%N")
			from i:= 0
			until i = lst_acteurs.count
			loop
				io.put_string(lst_acteurs.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end

end
















