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
  	mediatheque : MEDIATHEQUE

feature{ANY}
	make (m : MEDIATHEQUE) is
		do
			create lst_auteurs.with_capacity(1,0)
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
			create lst_livres.with_capacity(1,0)
			create lst_dvd.with_capacity(1,0)
			create lst_media_choisis.with_capacity(1,0)
			mediatheque := m
		end
		
	-- récupère tous les médias du fichier	
	remplir_lst_medias is
		local
			fichier: TEXT_FILE_READ -- Fichier media ouvert en lecture
			fichier2: TEXT_FILE_READ -- Fichier media ouvert en lecture
		do			
			-- Création et ouverture du fichier
			create fichier.make
			fichier.connect_to("medias.txt")
			analyser_fichier(fichier)			
			fichier.disconnect
			
			-- Création et ouverture du fichier
			create fichier2.make
			fichier2.connect_to("medias2.txt")
			if fichier2.is_connected then
				analyser_fichier(fichier2)			
				fichier2.disconnect
			end
		end
		
	analyser_fichier (fichier: TEXT_FILE_READ) is
		local
			ligne: STRING -- ligne du fichier média
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
			media : INTEGER
		do
			correct := False
			retour := False
			choix := 0
			reponse := ""
			reponse_int := 0
			resultat := 0
			media := 0
			
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
				correct := False
				from
				until correct
				loop
					io.put_string("1. Consulter détail")
					io.put_string("%N")
					io.put_string("2. Emprunter")
					io.put_string("%N")
					io.put_string("3. Retour")
					io.put_string("%N")
					io.flush
					io.read_integer
					reponse_int := io.last_integer
					if reponse_int > 0 and reponse_int < 4 then
						correct := True
						if reponse_int = 1 then
							io.put_string("Sur quel média voulez vous plus de détails ? (saisissez son numéro) %N")
							io.flush
							io.read_integer
							media := io.last_integer
							media := media - 1
							afficher_detail_media(media)
						end
						if reponse_int = 2 then 
							io.put_string("Quel media souhaitez vous emprunter? (saississez un numéro) %N")
							io.flush
							io.read_integer
							media := io.last_integer
							media := media - 1
							emprunter_un_media(media)
						end
					else
						io.put_string("Veuillez taper soit 1, 2 ou 3")
						io.put_string("%N")
					end
				end
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
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*          AJOUTER DVD         *")
			io.put_string("%N")
			io.put_string("********************************")
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
				    io.put_string("Prénom ? ")
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
			fichier.connect_for_appending_to("medias2.txt")
			fichier.put_line(ligne)
			fichier.disconnect
			 
		end
		
	ajouter_livre is
	    local
	    	livre : LIVRE
	    	auteur : AUTEUR
	    	titre, nom, prenom : STRING
	    	nb_exemplaires : INTEGER
	    	indice : INTEGER
	    	correct : BOOLEAN
	    	choix, ligne : STRING
			fichier : TEXT_FILE_WRITE
	    do
	    	nom := ""
			prenom := ""
			titre := ""
			ligne := ""
			choix := ""
			nb_exemplaires := 1
			
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*         AJOUTER LIVRE        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("%N")

			io.put_string("Titre du livre ? ")
			io.flush
			io.read_line
			io.read_line
			titre.copy(io.last_string)
			indice := verifier_lst_media(titre)
			
			if indice = -1 then
			    create livre.make			    
			    livre.set_titre(titre)
			    
			    create auteur.make
			    io.put_string("Nom de l'auteur ? ")
			    io.flush
				io.read_line
				nom.copy(io.last_string)
				auteur.set_nom(nom)
				
			    io.put_string("Prénom de l'auteur ? ")
			    io.flush
				io.read_line
				prenom.copy(io.last_string)
				
				auteur.set_prenom(prenom)
				livre.set_auteur(auteur)
				remplir_lst_auteurs(livre)
			    
			    correct := False
			    from
			    until correct
			    loop
				    io.put_string("Nombre d'exemplaires ? ")
				    io.flush
				    io.read_integer
				    nb_exemplaires := io.last_integer
				    if nb_exemplaires >= 0 and nb_exemplaires <= 1000 then
				        livre.set_nombre_exemplaires(nb_exemplaires)
					    correct := True
				    else
						io.put_string("Veuillez taper un nombre")
						io.put_string("%N")
						correct := False
				    end
			    end
			    
			    lst_livres.add_last(livre)
			  
			else -- si livre existe déjà
				io.put_string("Le média existe déjà.")
				correct := False
				livre := lst_livres.item(indice)
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
						    lst_livres.item(indice).set_nombre_exemplaires(lst_livres.item(indice).get_nombre_exemplaires+1)
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N %
                                  %pour Non")
							io.put_string("%N")
						end
					end
				end
			end -- fin if livre existe
			
			ligne.append("Livre ; Titre<"+livre.get_titre+"> ; Auteur<"+livre.get_auteur.get_prenom+" "+livre.get_auteur.get_nom+"> ")
			if livre.get_nombre_exemplaires > 1 then
			    ligne.append("; Nombre<"+livre.get_nombre_exemplaires.to_string+">")
			end
			
			create fichier.make
			fichier.connect_for_appending_to("medias2.txt")
			fichier.put_line(ligne)
			fichier.disconnect
	    end
	    
	remplir_lst_reservations is
		local
			index_start : INTEGER
			index_end : INTEGER
			titre : STRING
			identifiant : STRING
			fichier : TEXT_FILE_READ
			ligne_tab : ARRAY[STRING]
			ligne : STRING
			i, j : INTEGER
			index_user : INTEGER
			index_livre : INTEGER
			index_dvd : INTEGER
			user : UTILISATEUR
			dvd: DVD
			livre: LIVRE
			une_resa : RESERVATION
			priorite : INTEGER
			resa_ajouter : BOOLEAN
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""
			identifiant := ""
			create fichier.make
			fichier.connect_to("reservations.txt")
			if fichier.is_connected then
		
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
						index_dvd := 0
						index_livre := 0
						index_user := 0
						priorite := 1
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
						from j :=0
						until j = ligne_tab.count
						loop
					
							if ligne_tab.item(j).has_substring("Utilisateur")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								identifiant.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_users.count
								loop
									if identifiant.is_equal(mediatheque.get_lst_users.item(i).get_identifiant) then
										index_user := i 
										user := mediatheque.get_lst_users.item(i)
									end							
									i := i+1
								end													
							end -- end si case utilisateur
						
							if ligne_tab.item(j).has_substring("DVD")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = lst_dvd.count
								loop
									if titre.is_equal(lst_dvd.item(i).get_titre) then
										index_dvd := i 
										dvd := lst_dvd.item(i)
									end							
									i := i+1
								end													
							end -- end DVD
						
							if ligne_tab.item(j).has_substring("LIVRE")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = lst_livres.count
								loop
									if titre.is_equal(lst_livres.item(i).get_titre) then
										index_livre := i 
										livre := lst_livres.item(i)
									end							
									i := i+1
								end													
							end -- end livre
							if ligne_tab.item(j).has_substring("Priorite")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								priorite := (ligne_tab.item(j).substring(index_start+1, index_end-1)).to_integer
							end 
							j := j+1
						end -- end loop parcours ligne
						create une_resa.make
						une_resa.set_user(user)
						une_resa.set_priorite(priorite)
						if index_dvd > 0 then
							une_resa.set_dvd(dvd)
							resa_ajouter := lst_dvd.item(index_dvd).ajouter_reservation(une_resa)
						else
							une_resa.set_livre(livre)
							resa_ajouter := lst_livres.item(index_livre).ajouter_reservation(une_resa)
						end
						resa_ajouter := mediatheque.get_lst_users.item(index_user).ajouter_reservation(une_resa)
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							resa_ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
			
		end
		
	remplir_lst_emprunts is
		local
			index_start : INTEGER
			index_end : INTEGER
			titre : STRING
			identifiant : STRING
			fichier : TEXT_FILE_READ
			ligne_tab : ARRAY[STRING]
			ligne : STRING
			i, j : INTEGER
			index_user : INTEGER
			index_livre : INTEGER
			index_dvd : INTEGER
			user : UTILISATEUR
			dvd: DVD
			livre: LIVRE
			un_emp : EMPRUNT
			emp_ajouter : STRING
			emp_ajouter_media : BOOLEAN
			
		do
			-- initialisation
			index_start := 1
			index_end := 1
			titre := ""
			identifiant := ""
			create fichier.make
			fichier.connect_to("emprunts.txt")
			if fichier.is_connected then
		
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
						index_dvd := 0
						index_livre := 0
						index_user := 0
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
						from j :=0
						until j = ligne_tab.count
						loop
					
							if ligne_tab.item(j).has_substring("Utilisateur")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								identifiant.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = mediatheque.get_lst_users.count
								loop
									if identifiant.is_equal(mediatheque.get_lst_users.item(i).get_identifiant) then
										index_user := i 
										user := mediatheque.get_lst_users.item(i)
									end							
									i := i+1
								end													
							end -- end si case utilisateur
						
							if ligne_tab.item(j).has_substring("DVD")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = lst_dvd.count
								loop
									if titre.is_equal(lst_dvd.item(i).get_titre) then
										index_dvd := i 
										dvd := lst_dvd.item(i)
									end							
									i := i+1
								end													
							end -- end DVD
						
							if ligne_tab.item(j).has_substring("LIVRE")  then 
								index_start := ligne_tab.item(j).index_of('<', 1)
								index_end := ligne_tab.item(j).index_of('>', index_start)
								titre.copy(ligne_tab.item(j).substring(index_start+1, index_end-1))
								from i:= 0
								until i = lst_livres.count
								loop
									if titre.is_equal(lst_livres.item(i).get_titre) then
										index_livre := i 
										livre := lst_livres.item(i)
									end							
									i := i+1
								end													
							end -- end livre							
							j := j+1
						end -- end loop parcours ligne
						create un_emp.make
						un_emp.set_user(user)
						if index_dvd > 0 then
							un_emp.set_dvd(dvd)
							emp_ajouter := lst_dvd.item(index_dvd).ajouter_emprunt(un_emp)
						else
							un_emp.set_livre(livre)
							emp_ajouter := lst_livres.item(index_livre).ajouter_emprunt(un_emp)
						end
						emp_ajouter_media := mediatheque.get_lst_users.item(index_user).ajouter_emprunt(un_emp)
						if identifiant = mediatheque.get_utilisateur_connecte.get_identifiant then
							emp_ajouter_media := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emp)
						end
					end -- end ligne.count >0
				end -- end parcours fichier
				fichier.disconnect
			end -- end si fichier existe
		end
		
	
	afficher_media_choisi is
		local
			i, j: INTEGER
		do
			from i:= 0
			until i = lst_media_choisis.count
			loop
				j := i+1
				io.put_string("%T "+j.to_string+" -")
				io.put_string(lst_media_choisis.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	afficher_detail_media(choix_media : INTEGER) is
		local
			livre : LIVRE
			dvd : DVD
			i,j : INTEGER
		do
			from i:= 0
			until i = lst_media_choisis.count
			loop
				if i = choix_media then
					if lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = lst_livres.count
						loop
							if lst_livres.item(j).get_titre = lst_media_choisis.item(i).get_titre then
								livre := lst_livres.item(j)
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = lst_dvd.count
						loop
							if lst_dvd.item(j).get_titre = lst_media_choisis.item(i).get_titre then
								dvd := lst_dvd.item(j)
							end
							j := j+1
						end
					end
				end
				i := i+1
			end
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      DETAIL MEDIA CHOISI     *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			if livre /= Void then
				io.put_string("Titre : "+livre.get_titre)
				io.put_string("%N")
				io.put_string("Auteur : "+livre.get_auteur.get_prenom+" "+livre.get_auteur.get_nom)
				io.put_string("%N")
				io.put_string("Nombre d'exemplaire : ")
				io.put_integer(livre.get_nombre_exemplaires)
				io.put_string("%N")
			else
				io.put_string("Titre : "+dvd.get_titre)
				io.put_string("%N")
				io.put_string("Année de parution : ")
				io.put_integer(dvd.get_annee)
				io.put_string("%N")
				io.put_string("Nombre d'exemplaire : ")
				io.put_integer(dvd.get_nombre_exemplaires)
				io.put_string("%N")
				io.put_string("*** Liste des acteurs ***")
				io.put_string("%N")
				from i:= 0
				until i = dvd.get_lst_acteurs.count
				loop
					io.put_string("- "+dvd.get_lst_acteurs.item(i).get_prenom+" "+dvd.get_lst_acteurs.item(i).get_nom)
					io.put_string("%N")
					i := i+1
				end
				io.put_string("%N")
				io.put_string("*** Liste des réalisateurs ***")
				io.put_string("%N")
				from i:= 0
				until i = dvd.get_lst_realisateurs.count
				loop
					io.put_string("- "+dvd.get_lst_realisateurs.item(i).get_prenom+" "+dvd.get_lst_realisateurs.item(i).get_nom)
					io.put_string("%N")
					i := i+1
				end
			end
					
		end
		
	emprunter_un_media(choix_media : INTEGER) is
		local
			livre : LIVRE
			dvd : DVD
			i,j : INTEGER
			is_livre : BOOLEAN
			un_emprunt : EMPRUNT
			une_resa : RESERVATION
			ajouter : BOOLEAN
			ajouter_ds_media : STRING
			correct : BOOLEAN
			reserver : BOOLEAN
			choix : STRING
			fichier_emprunt : TEXT_FILE_WRITE
			fichier_reservation : TEXT_FILE_WRITE
		do
			is_livre := False
			ajouter := False
			
			from i:= 0
			until i = lst_media_choisis.count
			loop
				if i = choix_media then
					if lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = lst_livres.count
						loop
							if lst_livres.item(j).get_titre = lst_media_choisis.item(i).get_titre then
								livre := lst_livres.item(j)
								is_livre := True
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = lst_dvd.count
						loop
							if lst_dvd.item(j).get_titre = lst_media_choisis.item(i).get_titre then
								dvd := lst_dvd.item(j)
							end
							j := j+1
						end
					end
				end
				i := i+1
			end
			reserver := False
			if is_livre then
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_livre(livre)
				ajouter_ds_media := livre.ajouter_emprunt(un_emprunt)
				if ajouter_ds_media = "NON" then
					correct := False
					from
					until correct
					loop
						io.put_string("Ce livre est déjà emprunté, souhaitez vous le réserver ? (O/N) %N")
						io.flush
						io.read_line
						io.read_line
						choix := io.last_string
						if choix.is_equal("O") or choix.is_equal("N") then
							correct := True
							if choix.is_equal("O") then
								reserver := True
							end
						end
					end	
				end	
				if ajouter_ds_media.is_equal("FAIT") then
					io.put_string("Vous empruntez déjà ce livre! %N")
					reserver := False
				end			
				if ajouter_ds_media.is_equal("OUI") then
					ajouter := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emprunt)
					if not ajouter then
						correct := False
						from
						until correct
						loop
							io.put_string("Vous avez déjà emprunté trois médias, souhaitez vous réserver ce livre? (O/N) %N")
							io.flush
							io.read_line
							io.read_line
							choix := io.last_string
							if choix.is_equal("O") or choix.is_equal("N") then
								correct := True
								if choix.is_equal("O") then
									reserver := True
								end
							end
						end
					end	
				end
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré !%N")
				end
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_user(mediatheque.get_utilisateur_connecte)
					une_resa.set_livre(livre)
					ajouter := livre.ajouter_reservation(une_resa)
					if not ajouter then
						io.put_string("La réservation n'a pas pu être effectuée %N")
					end
					if ajouter then
						ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						if not ajouter then
							io.put_string("Vous ne pouvez pas réserver plus de trois médias simultanément %N")
						end
					end					
					if ajouter then
						create fichier_reservation.make
						fichier_reservation.connect_for_appending_to("reservations.txt")
						fichier_reservation.put_line(une_resa.format_enregistrement)
						fichier_reservation.disconnect
						io.put_string("Réservation effectuée ! %N")
					end
				end
			else
				create un_emprunt.make
				un_emprunt.set_user(mediatheque.get_utilisateur_connecte)
				un_emprunt.set_dvd(dvd)
				ajouter_ds_media := dvd.ajouter_emprunt(un_emprunt)
				if ajouter_ds_media.is_equal("NON") then
					correct := False
					from
					until correct
					loop
						io.put_string("Ce DVD est déjà emprunté, souhaitez vous le réserver ? (O/N) %N")
						io.flush
						io.read_line
						io.read_line
						choix := io.last_string
						if choix.is_equal("O") or choix.is_equal("N") then
							correct := True
							if choix.is_equal("O") then
								reserver := True
							end
						end
					end	
				end	
				if ajouter_ds_media.is_equal("FAIT") then
					io.put_string("Vous empruntez déjà ce DVD! %N")
					reserver := False
				end
				if ajouter_ds_media.is_equal("OUI") then
					ajouter := mediatheque.get_utilisateur_connecte.ajouter_emprunt(un_emprunt)
					if not ajouter then
						correct := False
						from
						until correct
						loop
							io.put_string("Vous avez déjà emprunté trois médias, souhaitez vous réserver ce DVD? (O/N) %N")
							io.flush
							io.read_line
							io.read_line
							choix := io.last_string
							if choix.is_equal("O") or choix.is_equal("N") then
								correct := True
								if choix.is_equal("O") then
									reserver := True
								end
							end
						end
					end	
				end
				
				if ajouter then
					create fichier_emprunt.make
					fichier_emprunt.connect_for_appending_to("emprunts.txt")
					fichier_emprunt.put_line(un_emprunt.format_enregistrement)
					fichier_emprunt.disconnect
					io.put_string("Nouvel emprunt enregistré ! %N")
				end
				if not ajouter and reserver then
					create une_resa.make
					une_resa.set_user(mediatheque.get_utilisateur_connecte)
					une_resa.set_dvd(dvd)
					ajouter := dvd.ajouter_reservation(une_resa)
					if not ajouter then
						io.put_string("La réservation n'a pas pu être effectuée. %N")
					end
					if ajouter then
						ajouter := mediatheque.get_utilisateur_connecte.ajouter_reservation(une_resa)
						if not ajouter then
							io.put_string("Vous ne pouvez pas réserver plus de trois médias simultanément. %N")
						end
					end
					if ajouter then
						create fichier_reservation.make
						fichier_reservation.connect_for_appending_to("reservations.txt")
						fichier_reservation.put_line(une_resa.format_enregistrement)
						fichier_reservation.disconnect
						io.put_string("Réservation effectuée ! %N")
					end
				end
			end
		end
		
	gerer_emprunt_reservation is
		local
			continuer : BOOLEAN
			choix_gestion : INTEGER
		do
			continuer := True
			from
			until not continuer
			loop
				io.put_string("Que souhaiter vous faire? %N")
				io.put_string("1. Consulter mes réservations %N")
				io.put_string("2. Consulter mes emprunts %N")
				io.put_string("3. Annuler une réservation %N")
				io.put_string("4. Retour %N")
				io.put_string("%N")
				io.flush
				io.read_integer
				choix_gestion := io.last_integer
				if choix_gestion > 0 and choix_gestion < 5 then
					inspect choix_gestion
					when 1 then 
						afficher_reservations
					when 2 then
						afficher_emprunts
					when 3 then
						annuler_reservation
					when 4 then
						continuer := False
					end
				else
					io.put_string("Saississez un nombre compris entre 1 et 4 %N")
				end
			end
		end
		
	afficher_reservations is
		local 
			i : INTEGER
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      MES RESERVATIONS        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_reservations.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre /= Void then
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre.to_string+"%N")
				else
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_dvd.to_string+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_reservations.count = 0 then
				io.put_string("Aucune réservation en cours ! %N")
			end
			io.put_string("%N %N")
		end
		
	afficher_emprunts is
		local 
			i : INTEGER
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      MES EMPRUNTS            *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_emprunts.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_livre /= Void then
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_livre.to_string+"%N")
				else
					io.put_string(mediatheque.get_utilisateur_connecte.get_lst_emprunts.item(i).get_dvd.to_string+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_emprunts.count = 0 then
				io.put_string("Aucun emprunt en cours ! %N")
			end
			io.put_string("%N %N")
		end
		
	annuler_reservation is 
		local 
			i : INTEGER
			choix : INTEGER
			correct : BOOLEAN
		do
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*      MES RESERVATIONS        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			from i := 0
			until i = mediatheque.get_utilisateur_connecte.get_lst_reservations.count
			loop
				if mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre /= Void then
					io.put_string((i+1).to_string + ". " + mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_livre.get_titre+"%N")
				else
					io.put_string((i+1).to_string + ". " + mediatheque.get_utilisateur_connecte.get_lst_reservations.item(i).get_dvd.get_titre+"%N")
				end
				i := i+1
			end
			if mediatheque.get_utilisateur_connecte.get_lst_reservations.count = 0 then
				io.put_string("Aucune réservation en cours ! %N")
			else
				correct := False
				from
				until correct 
				loop
					io.put_string("Quelle réservation souhaitez vous annuler ? (Saississez un numéro)%N")
					io.flush
					io.read_line
					choix := io.last_integer
					if choix > 0 and choix <= i then
						correct := True
						mediatheque.get_utilisateur_connecte.get_lst_reservations.remove(choix-1)
						io.put_string("Réservation annulée %N")
					end
				end
			end
			io.put_string("%N %N")
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
