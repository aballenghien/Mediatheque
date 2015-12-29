class GESTIONNAIRE_MEDIA

creation{ANY}
	make

feature{}
	lst_medias: ARRAY[MEDIA] -- liste des medias
 	lst_acteurs: ARRAY[ACTEUR] --liste des acteurs
 	lst_realisateurs: ARRAY[REALISATEUR] --liste des réalisateurs
  	lst_auteurs: ARRAY[AUTEUR] -- liste des auteurs
  	lst_livres: ARRAY[LIVRE] -- liste des livres
  	lst_dvd : ARRAY[DVD] -- liste des dvd
  	lst_media_choisis : ARRAY[MEDIA] -- liste des médias à afficher

feature{ANY}
	make is
		do
			create lst_auteurs.with_capacity(1,0)
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
			create lst_livres.with_capacity(1,0)
			create lst_dvd.with_capacity(1,0)
			create lst_media_choisis.with_capacity(1,0)
		end
		
	-- récupère tous les médias du fichier	
	remplir_lst_medias is
		local
			ligne: STRING -- ligne du fichier média
			fichier: TEXT_FILE_READ -- Fichier media ouvert en lecture
			i, index_start, index_end: INTEGER
			titre: STRING 
			livre: LIVRE
			dvd: DVD
			ligne_tab : ARRAY[STRING] -- découpage de la ligne avec les points virgules
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
						if ligne_tab.item(i).has_substring("Auteur") and is_livre then 
							index_start := ligne_tab.item(i).index_of('<', 1)							
							-- séparation du nom et prénom par l'espace
							index_end := ligne_tab.item(i).index_of(' ', index_start)
							create auteur.make
							auteur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						 	index_start := ligne_tab.item(i).index_of(' ', index_start)
						 	index_end := ligne_tab.item(i).index_of('>', 1)
						 	auteur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							livre.set_auteur(auteur)							
						end
						
						--si la case indique un acteur, on ajoute l'acteur à la liste pour le dvd
						if ligne_tab.item(i).has_substring("Acteur") and not is_livre then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							-- séparation du nom et prénom par l'espace
							index_end := ligne_tab.item(i).index_of(' ', index_start)
							create acteur.make
							acteur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
						 	index_start := ligne_tab.item(i).index_of(' ', index_start)
						 	index_end := ligne_tab.item(i).index_of('>', 1)
						 	acteur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							dvd.ajouter_acteur(acteur)
						end
						
						--si la case indique un réalisateur, on ajoute le réalisateur à la liste pour le dvd
						if ligne_tab.item(i).has_substring("Realisateur") and not is_livre then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of(' ', index_start)
							-- séparation du nom et prénom par l'espace
							create realisateur.make
							realisateur.set_prenom(ligne_tab.item(i).substring(index_start+1, index_end-1))
							index_start := ligne_tab.item(i).index_of(' ', index_start)
							index_end := ligne_tab.item(i).index_of('>', 1)
							realisateur.set_nom(ligne_tab.item(i).substring(index_start+1, index_end-1))						
							dvd.ajouter_realisateur(realisateur)
						end
						
						-- Si la case indique une année, on assigne l'année au dvd
						if ligne_tab.item(i).has_substring("Annee") and not is_livre then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', index_start)
							dvd.set_annee(ligne_tab.item(i).substring(index_start+1, index_end-1).to_integer)
						end
						
						-- Si la case indique un type, on assigne le type au dvd
						if ligne_tab.item(i).has_substring("Type") and not is_livre then 
							index_start := ligne_tab.item(i).index_of('<', 1)
							index_end := ligne_tab.item(i).index_of('>', index_start)
							dvd.set_type(ligne_tab.item(i).substring(index_start+1, index_end-1))
						end
						
						i := i + 1
					end
					
					--lst_medias.add_last(livre)
					-- Ajout du média dans le tableau correspondant
					if is_livre then				
						lst_livres.add_last(livre)
					else 
						lst_dvd.add_last(dvd)
					end					
				end							
			end
			fichier.disconnect
		end
	
	-- parcours les listes des dvd et des livres pour récupérer les 
	-- auteurs/réalisateurs/acteurs et remplir les trois listes correspondantes
	remplir_lst_auteurs_realisateurs_acteurs is
		local
			i: INTEGER
			un_dvd : DVD
			un_livre : LIVRE
		do
			-- parcours de la liste des livres pour remplir la liste des auteurs
			from i:= 0
			until i = lst_livres.count
			loop
				un_livre := lst_livres.item(i)
				remplir_lst_auteurs(un_livre)
				i := i+1
			end
			
			-- parcours de la liste des dvd pour remplir la liste des 
			-- acteurs et celle des réalisateurs
			from i:= 0
			until i = lst_dvd.count
			loop
				un_dvd := lst_dvd.item(i)
				remplir_lst_acteurs(un_dvd)
				remplir_lst_realisateurs(un_dvd)
				i := i+1
			end
		end

	--remplissage de la liste des auteurs
	remplir_lst_auteurs (un_livre: LIVRE) is
		local
			un_auteur : AUTEUR
			indice_trouver : INTEGER
		do
			un_auteur := un_livre.get_auteur
			if un_auteur /= Void then
				-- on cherche si l'auteur existe déjà dans lst_auteurs
				indice_trouver := verifier_lst_auteurs(un_auteur)
				-- si c'est le cas, on lie le livre à l'auteur dans la 
				-- liste auteur.lst_livres
				if indice_trouver >=0 then
					lst_auteurs.item(indice_trouver).ajouter_livre(un_livre)
				else
					-- sinon on lie le livre puis on ajoute l'auteur à la 
					-- liste des auteurs
					un_auteur.ajouter_livre(un_livre)
					lst_auteurs.add_last(un_auteur)
				end				
			end
		end

	-- remplissage de la liste des acteurs
	remplir_lst_acteurs(un_dvd : DVD) is
		local
			i : INTEGER
			acteurs : ARRAY[ACTEUR]
			indice_trouver : INTEGER
		do
			acteurs := un_dvd.get_lst_acteurs
			-- parcours de la listes des acteurs de chaque film
			from i:= 0
			until i = acteurs.count
			loop
				-- recherche de l'acteur dans la liste existante 
				indice_trouver := verifier_lst_acteurs(acteurs.item(i))
				-- s'il existe on lie le dvd à l'acteur dans la liste acteur.lst_films
				if indice_trouver >= 0 then
					lst_acteurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					-- sinon on lie le dvd à l'acteur et on ajoute 
					-- l'acteur à la liste des acteurs
					acteurs.item(i).ajouter_film(un_dvd)
					lst_acteurs.add_last(acteurs.item(i))
				end
				i:= i+1
			end
		end

	-- remplissage de la liste des réalisateurs
	remplir_lst_realisateurs(un_dvd : DVD) is
		local
			i : INTEGER
			realisateurs : ARRAY[REALISATEUR]
			indice_trouver : INTEGER
		do
			realisateurs := un_dvd.get_lst_realisateurs
			-- parcours de la listes des réalisateurs de chaque film
			from i:= 0
			until i = realisateurs.count
			loop
				-- recherche du réalisateur dans la liste existante
				indice_trouver := verifier_lst_realisateurs(realisateurs.item(i))
				-- s'il existe on lie le dvd au réalisateur dans la liste realisateur.lst_films
				if indice_trouver >= 0 then
					lst_realisateurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					-- sinon on lie le dvd au réalisateur et on ajoute 
					-- le réalisateurs à la liste des réalisateurs
					realisateurs.item(i).ajouter_film(un_dvd)
					lst_realisateurs.add_last(realisateurs.item(i))
				end
				i:= i+1
			end
		end
	
	-- Fonction qui vérifie si l'auteur passé en paramétre existe déjà ou non
	verifier_lst_auteurs(un_auteur : AUTEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			-- on parcourt la liste des auteurs
			from i := 0
			until i = lst_auteurs.count
			loop				
				-- test sur le nom et le prénom de l'auteur
				if un_auteur.get_prenom.is_equal(lst_auteurs.item(i).get_prenom) 
				and un_auteur.get_nom.is_equal(lst_auteurs.item(i).get_nom) then
					-- s'il existe on retourne son indice dans le tableau
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end	
	
	-- Fonction qui vérifie si l'acteur passé en paramétre existe déjà ou non	
	verifier_lst_acteurs(un_acteur : ACTEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			-- parcourt de la liste des acteurs
			from i := 0
			until i = lst_acteurs.count
			loop
				-- test sur le nom et le prénom de l'acteur
				if un_acteur.get_prenom.is_equal(lst_acteurs.item(i).get_prenom) 
				and	un_acteur.get_nom.is_equal(lst_acteurs.item(i).get_nom) then
					-- s'il existe on retourne son indice dans le tableau
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end	
		
	-- Fonction qui vérifie si le réalisateur passé en paramétre existe déjà ou non	
	verifier_lst_realisateurs(un_realisateur : REALISATEUR):INTEGER  is
		local
			i : INTEGER
			rst : INTEGER
		do
			rst := -1
			from i := 0
			until i = lst_realisateurs.count
			loop
				-- test sur le nom et le prénom du réalisateur
				if un_realisateur.get_prenom.is_equal(lst_realisateurs.item(i).get_prenom)
				and	un_realisateur.get_nom.is_equal(lst_realisateurs.item(i).get_nom) then
					-- s'il existe on retourne son indice dans le tableau
					rst := i
				end
				i := i + 1
			end
			Result := rst
		end

	verifier_lst_media(titre : STRING) : INTEGER is
		local
			i:INTEGER
			rst: INTEGER
		do
			rst := -1
			from i := 0
			until i = lst_dvd.count
			loop
				-- test sur le titre du dvd
				if lst_dvd.item(i).get_titre.is_equal(titre) then
					-- s'il existe on retourne son indice dans le tableau
					rst := i
				end
				i := i + 1
			end
			if rst = -1 then
				from i := 0
				until i = lst_livres.count
				loop
					-- test sur le titre du livre
					if lst_livres.item(i).get_titre.is_equal(titre) then
						-- s'il existe on retourne son indice dans le tableau
						rst := i
					end
					i := i + 1
				end
			end
			Result := rst
		end
	
	-- fonction recherchant un média dans la liste des médias
	rechercher_media is
		local
			choix : INTEGER
			reponse: STRING
			correct : BOOLEAN
			scorrect : BOOLEAN
			resultat : INTEGER
			type : STRING
			retour : BOOLEAN
			reponse_int : INTEGER
		do
			correct := False
			retour := False
			choix := 0
			reponse := ""
			reponse_int := 0
			resultat := 0
			
			from
			until correct
			loop
				-- On propose les différentes possiblités de recherche à l'utilisateur
				io.put_string("Choisissez un critère de recherche : ")
				io.put_string("%N")			
				io.put_string("1. Je sais quel type de média je cherche")
				io.put_string("%N")	
				io.put_string("2. Je connais le titre")
				io.put_string("%N")	
				io.put_string("3. Je connais un acteur")
				io.put_string("%N")	
				io.put_string("4. Je connais un auteur")
				io.put_string("%N")	
				io.put_string("5. Je connais un réalisateur")
				io.put_string("%N")	
				io.put_string("6. Je connais l'année de la parution du DVD")
				io.put_string("%N")	
				io.put_string("7. Retour")
				io.put_string("%N")	
	
				io.flush
				io.read_integer
				choix := io.last_integer

				if choix > 0 and choix < 9 then
					correct :=True
					inspect choix
					-- Pour le choix 1, recherche par type
					when 1 then
						scorrect := False
						from 
						until scorrect
						loop
							io.put_string("Vous recherchez : 1: Un DVD, 2: Un Livre ?")
							io.put_string("%N")
							io.flush
							io.read_integer
							reponse_int := io.last_integer
							if reponse_int = 1 then
								scorrect := True
								type := "DVD"
							end
							if reponse_int = 2 then
								scorrect := True
								type := "LIVRE"
							end
						end
						resultat := rechercher_media_par_type(type)
						
					-- Choix 2, recherche par titre (DVD et livre)
					when 2 then
						io.put_string("Donnez le titre ou une partie du titre:")
						io.put_string("%N")
						io.flush
						io.read_line
						io.read_line
						reponse.copy(io.last_string)
						resultat := rechercher_media_par_titre(reponse)

					-- choix 3, recherche par acteur
					when 3 then
						io.put_string("Donnez le nom et/ou le prenom de l'acteur (au format nom/prenom)")
						io.put_string("%N")
						io.flush
						io.read_line
						io.read_line
						reponse.copy(io.last_string)
						scorrect := False
						from
						until scorrect
						loop
							if reponse.has_substring("/") then
								scorrect := True
							else
								io.put_string("Le format est nom/prenom")
								io.put_string("%N")
								io.flush
								io.read_line
								reponse.copy(io.last_string)
							end
						end	
						resultat := rechercher_media_par_personne("ACTEUR",reponse)

					-- choix 4, recherche par auteur
					when 4 then
						io.put_string("Donnez le nom et/ou le prenom de l'auteur (au format nom/prenom)")
						io.put_string("%N")
						io.flush
						io.read_line
						io.read_line
						reponse.copy(io.last_string)
						scorrect := False
						from
						until scorrect
						loop
							if reponse.has_substring("/") then
								scorrect := True
							else
								io.put_string("Le format est nom/prenom")
								io.put_string("%N")
								io.flush
								io.read_line
								reponse.copy(io.last_string)
							end
						end	
						resultat := rechercher_media_par_personne("AUTEUR",reponse)

					-- choix 5, recherche par réalisateur
					when 5 then
						io.put_string("Donnez le nom et/ou le prenom du réalisateur (au format nom/prenom)")
						io.put_string("%N")
						io.flush
						io.read_line
						io.read_line
						reponse.copy(io.last_string)
						scorrect := False
						from
						until scorrect
						loop
							if reponse.has_substring("/") then
								scorrect := True
							else
								io.put_string("Le format est nom/prenom")
								io.put_string("%N")
								io.flush
								io.read_line
								reponse.copy(io.last_string)
							end
						end	
						resultat := rechercher_media_par_personne("REALISATEUR",reponse)

					-- choix6 ,recherche par année
					when 6 then
						from
						until scorrect
						loop
							io.put_string("En quel année est sortie le DVD ?")
							io.put_string("%N")
							io.flush
							io.read_integer
							reponse_int := io.last_integer
							if reponse_int > 1000 and reponse_int < 9999 then
								scorrect := True
							else
								io.put_string("Donnez une année sur quatres chiffres")
								io.put_string("%N")
							end
						end
						resultat := rechercher_media_par_annee(reponse_int)
						
					when 7 then
						retour := True	
					end
				else
					io.put_string("Veuillez choisir un chiffre entre 1 et 7")
					io.put_string("%N")
				end
			end
			if retour = False then
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*      RESULTAT RECHERCHE      *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("Nous avons trouvé "+resultat.to_string+" médias correspondants à votre recherche :")
				io.put_string("%N")
				afficher_media_choisi
				io.put_string("%N")
			end
		end
		
	-- Cherche les médias par type
	rechercher_media_par_type (type:STRING):INTEGER is
		do
			-- On remplit la liste media_choisis
			create lst_media_choisis.with_capacity(1,0)
			-- si le type choisi est livre
			if type.is_equal("LIVRE") then
				-- la liste est = à celle des livres
				lst_media_choisis := lst_livres
			else
				-- sinon la liste est = à celle des DVD
				lst_media_choisis := lst_dvd
			end
			-- on renvoie le nombre d'élément de la liste
			Result := lst_media_choisis.count
		end
		
	-- Cherche les médias par titre
	rechercher_media_par_titre (titre: STRING) : INTEGER is
		local
			i: INTEGER
		do
			-- On remplit la liste media_choisis
			create lst_media_choisis.with_capacity(1,0)
			-- on cherche d'abord dans la liste des livres
			from i:=0
			until i = lst_livres.count
			loop
				if lst_livres.item(i).get_titre.has_substring(titre) then
					lst_media_choisis.add_last(lst_livres.item(i))
				end
				i := i+1
			end
			-- on cherche ensuite dans la liste des dvd
			from i:=0
			until i = lst_dvd.count
			loop
				if lst_dvd.item(i).get_titre.has_substring(titre) then
					lst_media_choisis.add_last(lst_dvd.item(i))
				end
				i := i+1
			end
			-- on renvoie le nombre d'élément de la liste
			Result := lst_media_choisis.count
		end
		
	-- Recherche un média par nom/prenom d'auteur/acteur/réalisateur
	rechercher_media_par_personne (type_personne: STRING; nom_prenom : STRING) : INTEGER is
		local
			i,j : INTEGER
			nom : STRING
			prenom : STRING
		do
			create lst_media_choisis.with_capacity(1,0)
			-- on récupére seulement le nom et le prénom
			nom := nom_prenom.substring(1, nom_prenom.index_of('/',1)-1)
			prenom := nom_prenom.substring(nom_prenom.index_of('/',1)+1, nom_prenom.last_index_of(nom_prenom.last))
			-- Recherche par auteur
			if type_personne.is_equal("AUTEUR") then
				from i:= 0
				until i = lst_auteurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if lst_auteurs.item(i).get_nom.is_equal(nom) 
						and lst_auteurs.item(i).get_prenom.is_equal(prenom) then
							-- on récupére tous les livres liés à l'auteur
							from j := 0
							until j = lst_auteurs.item(i).get_lst_livres.count
							loop
								lst_media_choisis.add_last(lst_auteurs.item(i).get_lst_livres.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if lst_auteurs.item(i).get_nom.is_equal(nom) then
								-- on récupére tous les livres liés à l'auteur
								from j := 0
								until j = lst_auteurs.item(i).get_lst_livres.count
								loop
									lst_media_choisis.add_last(lst_auteurs.item(i).get_lst_livres.item(j))
									j := j+1
								end
							end
						end
					end
					i:= i+1
				end
			end
			
			-- Recherche par acteur
			if type_personne.is_equal("ACTEUR") then
				from i:= 0
				until i = lst_acteurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if lst_acteurs.item(i).get_nom.is_equal(nom) 
						and lst_acteurs.item(i).get_prenom.is_equal(prenom) then
							-- on récupére tous les dvd liés à l'acteur
							from j := 0
							until j = lst_acteurs.item(i).get_lst_films.count
							loop
								lst_media_choisis.add_last(lst_acteurs.item(i).get_lst_films.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if lst_acteurs.item(i).get_nom.is_equal(nom) then
								-- on récupére tous les dvd liés à l'acteur
								from j := 0
								until j = lst_acteurs.item(i).get_lst_films.count
								loop
									lst_media_choisis.add_last(lst_acteurs.item(i).get_lst_films.item(j))
									j := j+1
								end
							end
						end
					end
					i:= i+1
				end
			end
			
			-- recherche par réalisateur
			if type_personne.is_equal("REALISATEUR") then
				from i:= 0
				until i = lst_realisateurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if lst_realisateurs.item(i).get_nom.is_equal(nom) 
						and lst_realisateurs.item(i).get_prenom.is_equal(prenom) then
							-- on récupére tous les dvd liés au réalisateur
							from j := 0
							until j = lst_realisateurs.item(i).get_lst_films.count
							loop
								lst_media_choisis.add_last(lst_realisateurs.item(i).get_lst_films.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if lst_realisateurs.item(i).get_nom.is_equal(nom) then
								-- on récupére tous les dvd liés au réalisateur
								from j := 0
								until j = lst_realisateurs.item(i).get_lst_films.count
								loop
									lst_media_choisis.add_last(lst_realisateurs.item(i).get_lst_films.item(j))
									j := j+1
								end
							end
						end
					end					
					i:= i+1
				end
			end
			Result := lst_media_choisis.count
		end
			
	-- recherche un dvd par année
	rechercher_media_par_annee(annee: INTEGER) : INTEGER is
		local
			i : INTEGER
		do
			create lst_media_choisis.with_capacity(1,0)
			-- on parcourt la liste des dvd
			from i:= 0
			until i = lst_dvd.count
			loop
				-- si l'année est égale à celle saisie, on ajoute à la liste
				if lst_dvd.item(i).get_annee = annee then
					lst_media_choisis.add_last(lst_dvd.item(i))
				end
				i := i+1
			end
			Result := lst_media_choisis.count
		end

--afficher menu ajouter media
	ajouter_media is
		local
			choix : INTEGER
			correct : BOOLEAN
		do
			correct := False
			from
			until correct
			loop				
				io.put_string("1. Ajouter un DVD %N")
				io.put_string("2. Ajouter un livre %N")
				io.put_string("3. Retour au menu principal %N")
				io.flush
				io.read_integer
				choix := io.last_integer
						
				if choix > 0 and choix < 4 then
					inspect choix
					when 1 then 
						ajouter_dvd
						correct := True					
					when 2 then
						ajouter_livre
						correct := True					
					when 3 then
						correct := True					
					end -- end inspect
				else
					io.put_string("Votre choix n'existe pas, Tapez 1,2 ou 3 %N")
				end -- end if
			end -- end loop
		end -- end fonction
		

 --ajouter un dvd   
	ajouter_dvd is
		local
			titre, nom, prenom, type: STRING
			ligne, choix : STRING
			fichier : TEXT_FILE_WRITE
			dvd : DVD
			correct : BOOLEAN
			indice : INTEGER
			nb_exemplaires : INTEGER
			annee : INTEGER
			ajout : BOOLEAN
			realisateur : REALISATEUR
			acteur : ACTEUR
			i : INTEGER
		do
			nom := ""
			prenom := ""
			titre := ""
			type := ""
			ligne := ""
			choix := ""
			nb_exemplaires := 1
			
			
			io.put_string("*** Ajouter un nouveau DVD ***")
			io.put_string("%N")

			io.put_string("Titre du DVD ? ")
			io.flush
			io.read_line
			io.read_line
			titre.copy(io.last_string)
			indice := verifier_lst_media(titre)
			
			if indice = -1 then
			    create dvd.make			    
			    dvd.set_titre(titre)
			    
			    correct := False
			    from
			    until correct
			    loop
				    io.put_string("Nombre d'exemplaires ? ")
				    io.flush
				    io.read_integer
				    nb_exemplaires := io.last_integer
				    if nb_exemplaires >= 0 and nb_exemplaires <= 1000 then
				        dvd.set_nombre_exemplaires(nb_exemplaires)
					    correct := True
				    else
						io.put_string("Veuillez taper un nombre")
						io.put_string("%N")
						correct := False
				    end
			    end	
			    
			    correct := False
			    from
			    until correct
			    loop
				    io.put_string("Année de sortie du DVD ? ")
				    io.flush
				    io.read_integer
				    annee := io.last_integer
				    if annee >= 1000 and annee <= 9999 then
				        dvd.set_annee(annee)
					    correct := True
				    else
						io.put_string("Veuillez taper une année sur 4 chiffres")
						io.put_string("%N")
						correct := False
				    end
			    end	
				
				
				-- ajouter des réalisateurs
				io.put_string("*** Ajout des réalisateurs *** %N")
				ajout := True
				from
				until not ajout
				loop
				    create realisateur.make
				    io.put_string("Nom ? ")
				    io.flush
				    io.read_line
				    io.read_line
				    nom.copy(io.last_string)
				    realisateur.set_nom(nom)
				    io.put_string("Prenom ? ")
				    io.flush
				    io.read_line
				    prenom.copy(io.last_string)
				    realisateur.set_prenom(prenom)
				    dvd.ajouter_realisateur(realisateur)
				    correct := False
				    from
				    until correct
				    loop
					    io.put_string("Souhaitez vous ajouter un autre réalisateur ? (O/N)")
					    io.flush
					    io.read_line
					    choix.copy(io.last_string)
					    if choix.is_equal("N") then
					        ajout := False
						    correct := True
					    else
						    if choix.is_equal("O") then
						        ajout := True
							    correct := True
						    else
							    io.put_string("Veuillez taper O pour Oui ou N %
                                      %pour Non")
							    io.put_string("%N")
						    end
					    end
				    end	
				end -- fin ajouter realisateur
				
				-- ajouter des acteurs
				io.put_string("*** Ajout des acteurs *** %N")
				ajout := True
				from
				until not ajout
				loop
				    create acteur.make
				    io.put_string("Nom ? ")
				    io.flush
				    io.read_line
				    nom.copy(io.last_string)
				    acteur.set_nom(nom)
				    io.put_string("Prenom ? ")
				    io.flush
				    io.read_line
				    prenom.copy(io.last_string)
				    acteur.set_prenom(prenom)
				    dvd.ajouter_acteur(acteur)
				    correct := False
				    from
				    until correct
				    loop
					    io.put_string("Souhaitez vous ajouter un autre acteur ? (O/N)")
					    io.flush
					    io.read_line
					    choix.copy(io.last_string)
					    if choix.is_equal("N") then
					        ajout := False
						    correct := True
					    else
						    if choix.is_equal("O") then
						        ajout := True
							    correct := True
						    else
							    io.put_string("Veuillez taper O pour Oui ou N %
                                      %pour Non")
							    io.put_string("%N")
						    end
					    end
				    end	
				end	-- fin ajouter acteur
				
				remplir_lst_realisateurs(dvd)
				remplir_lst_acteurs(dvd)
				lst_dvd.add_last(dvd)
				
				-- le dvd est-il un coffret ?
				correct := False
			    from
			    until correct
			    loop
				    io.put_string("Le DVD est-il au format coffret ? (O/N) %N")
				    io.flush
				    io.read_line
				    choix.copy(io.last_string)
				    if choix.is_equal("N") then
					    correct := True
				    else
					    if choix.is_equal("O") then
					        dvd.set_type("Coffret")
						    correct := True
					    else
						    io.put_string("Veuillez taper O pour Oui ou N %
                                  %pour Non")
						    io.put_string("%N")
					    end
				    end
			    end
				
			else -- si dvd existe déjà
				io.put_string("Le média existe déjà.")
				correct := False
				dvd := lst_dvd.item(indice)
				from
				until correct
				loop
					io.put_string("Souhaitez vous ajouter un exemplaire ? (O/N) %N")
					io.flush
					io.read_line
					choix.copy(io.last_string)
					if choix.is_equal("N") then
						correct := True
					else
						if choix.is_equal("O") then
						    lst_dvd.item(indice).set_nombre_exemplaires(lst_dvd.item(indice).get_nombre_exemplaires+1)
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N %
                                  %pour Non")
							io.put_string("%N")
						end
					end
				end
			end -- fin if dvd existe
			
			ligne.append("DVD ; Titre<"+dvd.get_titre+"> ; Annee<"+dvd.get_annee.to_string+"> ; ")
			from i:= 0
			until i = dvd.get_lst_realisateurs.count
			loop
			    ligne.append("Realisateur<"+dvd.get_lst_realisateurs.item(i).get_prenom+" "+dvd.get_lst_realisateurs.item(i).get_nom+ ">; ")
			    i := i + 1
			end
			from i:= 0
			until i = dvd.get_lst_acteurs.count
			loop
			    ligne.append("Acteur<"+dvd.get_lst_acteurs.item(i).get_prenom+" "+dvd.get_lst_acteurs.item(i).get_nom+ ">; ")
			    i := i + 1
			end
			if dvd.get_type.is_equal("Coffret") then
			    ligne.append("Type<"+dvd.get_type+"> ; ")
			end
			if dvd.get_nombre_exemplaires > 1 then
			    ligne.append("Nombre<"+dvd.get_nombre_exemplaires.to_string+">")
			end
			
			create fichier.make
			fichier.connect_for_appending_to("media2.txt")
			fichier.put_line(ligne)
			fichier.disconnect
			 
		end
		
	ajouter_livre is
	    local
	    do
	    end	
	
	afficher_media_choisi is
		local
			i: INTEGER
		do
			from i:= 0
			until i = lst_media_choisis.count
			loop
				io.put_string("%T -")
				io.put_string(lst_media_choisis.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
	
	get_lst_acteurs : ARRAY[ACTEUR] is
		do
			Result := lst_acteurs
		end
	
	get_lst_realisateurs : ARRAY[REALISATEUR] is
		do
			Result := lst_realisateurs
		end
	
	get_lst_auteurs : ARRAY[AUTEUR] is
		do
			Result := lst_auteurs
		end
	
	get_lst_livres : ARRAY[LIVRE] is
		do
			Result := lst_livres
		end
	
	get_lst_dvd : ARRAY[DVD] is
		do
			Result := lst_dvd
		end
	
	get_lst_media_choisis : ARRAY[MEDIA] is
		do
			Result := lst_media_choisis
		end
end
