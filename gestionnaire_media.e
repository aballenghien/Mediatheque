class GESTIONNAIRE_MEDIA

creation{ANY}
	make

feature{}	
  	mediatheque : MEDIATHEQUE

feature{ANY}
	make (m : MEDIATHEQUE) is
		do
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
			i, index_start, index_end, position: INTEGER
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
						position := livre_existe(livre)
						if position = -1 then		
							mediatheque.get_lst_livres.add_last(livre)
						else
							mediatheque.get_lst_livres.item(position).ajouter_un_exemplaire
						end
					else 
						position := dvd_existe(dvd)
						if position = -1 then		
							mediatheque.get_lst_dvd.add_last(dvd)
						else
							mediatheque.get_lst_dvd.item(position).ajouter_un_exemplaire
						end
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
			until i = mediatheque.get_lst_livres.count
			loop
				un_livre := mediatheque.get_lst_livres.item(i)
				remplir_lst_auteurs(un_livre)
				i := i+1
			end
			
			-- parcours de la liste des dvd pour remplir la liste des 
			-- acteurs et celle des réalisateurs
			from i:= 0
			until i = mediatheque.get_lst_dvd.count
			loop
				un_dvd := mediatheque.get_lst_dvd.item(i)
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
					mediatheque.get_lst_auteurs.item(indice_trouver).ajouter_livre(un_livre)
				else
					-- sinon on lie le livre puis on ajoute l'auteur à la 
					-- liste des auteurs
					un_auteur.ajouter_livre(un_livre)
					mediatheque.get_lst_auteurs.add_last(un_auteur)
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
					mediatheque.get_lst_acteurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					-- sinon on lie le dvd à l'acteur et on ajoute 
					-- l'acteur à la liste des acteurs
					acteurs.item(i).ajouter_film(un_dvd)
					mediatheque.get_lst_acteurs.add_last(acteurs.item(i))
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
					mediatheque.get_lst_realisateurs.item(indice_trouver).ajouter_film(un_dvd)
				else
					-- sinon on lie le dvd au réalisateur et on ajoute 
					-- le réalisateurs à la liste des réalisateurs
					realisateurs.item(i).ajouter_film(un_dvd)
					mediatheque.get_lst_realisateurs.add_last(realisateurs.item(i))
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
			until i = mediatheque.get_lst_auteurs.count
			loop				
				-- test sur le nom et le prénom de l'auteur
				if un_auteur.get_prenom.is_equal(mediatheque.get_lst_auteurs.item(i).get_prenom) 
				and un_auteur.get_nom.is_equal(mediatheque.get_lst_auteurs.item(i).get_nom) then
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
			until i = mediatheque.get_lst_acteurs.count
			loop
				-- test sur le nom et le prénom de l'acteur
				if un_acteur.get_prenom.is_equal(mediatheque.get_lst_acteurs.item(i).get_prenom) 
				and	un_acteur.get_nom.is_equal(mediatheque.get_lst_acteurs.item(i).get_nom) then
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
			until i = mediatheque.get_lst_realisateurs.count
			loop
				-- test sur le nom et le prénom du réalisateur
				if un_realisateur.get_prenom.is_equal(mediatheque.get_lst_realisateurs.item(i).get_prenom)
				and	un_realisateur.get_nom.is_equal(mediatheque.get_lst_realisateurs.item(i).get_nom) then
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
			until i = mediatheque.get_lst_dvd.count
			loop
				-- test sur le titre du dvd
				if mediatheque.get_lst_dvd.item(i).get_titre.is_equal(titre) then
					-- s'il existe on retourne son indice dans le tableau
					rst := i
				end
				i := i + 1
			end
			if rst = -1 then
				from i := 0
				until i = mediatheque.get_lst_livres.count
				loop
					-- test sur le titre du livre
					if mediatheque.get_lst_livres.item(i).get_titre.is_equal(titre) then
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
			choix : STRING
			reponse: STRING
			correct : BOOLEAN
			scorrect : BOOLEAN
			surcorrect : BOOLEAN
			resultat : INTEGER
			type : STRING
			retour : BOOLEAN
			reponse_str : STRING
			media : STRING
			media_int : INTEGER
		do
			correct := False
			surcorrect := False
			retour := False
			choix := ""
			reponse := ""
			reponse_str := ""
			resultat := 0
			media := ""
			media_int := 0
			
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
	
				from 
				until surcorrect
				loop
					io.flush
					io.read_line
					choix.copy(io.last_string)
					if choix.is_integer then
						surcorrect := True
						if choix.to_integer > 0 and choix.to_integer < 9 then
							correct :=True
							inspect choix.to_integer
							-- Pour le choix 1, recherche par type
							when 1 then
								scorrect := False
								from 
								until scorrect
								loop
									io.put_string("Vous recherchez : 1: Un DVD, 2: Un Livre ?")
									io.put_string("%N")
									io.flush
									io.read_line
									reponse_str.copy(io.last_string)
									if reponse_str.is_integer then
										if reponse_str.to_integer = 1 then
											scorrect := True
											type := "DVD"
										end
										if reponse_str.to_integer = 2 then
											scorrect := True
											type := "LIVRE"
										end
									end
								end
								resultat := rechercher_media_par_type(type)
						
							-- Choix 2, recherche par titre (DVD et livre)
							when 2 then
								io.put_string("Donnez le titre ou une partie du titre:")
								io.put_string("%N")
								io.flush
								io.read_line
								reponse.copy(io.last_string)
								resultat := rechercher_media_par_titre(reponse)

							-- choix 3, recherche par acteur
							when 3 then
								io.put_string("Donnez le nom et/ou le prenom de l'acteur (au format nom/prenom)")
								io.put_string("%N")
								io.flush
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
									io.read_line
									reponse_str.copy(io.last_string)
									if reponse_str.is_integer then
										if reponse_str.to_integer > 1000 and reponse_str.to_integer < 9999 then
											scorrect := True
										else
											io.put_string("Donnez une année sur quatres chiffres")
											io.put_string("%N")
										end
									else
										io.put_string("Donnez une année sur quatres chiffres")
										io.put_string("%N")
									end
								end
								resultat := rechercher_media_par_annee(reponse_str.to_integer)
						
							when 7 then
								retour := True	
							end
						else
							io.put_string("Veuillez choisir un chiffre entre 1 et 7")
							io.put_string("%N")
						end
					else
						io.put_string("Tapez un nombre%N")
					end
				end
			end
			-- affichage des resultats de la recherche
			if retour = False then
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*      RESULTAT RECHERCHE      *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				-- affichage du nombre de média trouvé
				io.put_string("Nous avons trouvé "+resultat.to_string+" médias correspondants à votre recherche :")
				io.put_string("%N")
				-- s'il y a un média trouvé
				if resultat > 0 then
				    -- affichage de la liste des médias trouvé
					afficher_media_choisi
					io.put_string("%N")
					correct := False
					-- menu
					from
					until correct
					loop
						io.put_string("1. Consulter détail")
						io.put_string("%N")
						io.put_string("2. Emprunter")
						io.put_string("%N")
						if mediatheque.get_utilisateur_connecte.is_admin then
							io.put_string("3. Modifier")
							io.put_string("%N")
							io.put_string("4. Supprimer un media")
							io.put_string("%N")
							io.put_string("5. Retour")
							io.put_string("%N")
						else
							io.put_string("3. Retour")
							io.put_string("%N")
						end
						scorrect := False
						from
						until scorrect 
						loop
							io.flush
							io.read_line
							reponse_str.copy(io.last_string)
							if reponse_str.is_integer then
								scorrect := True
								if (reponse_str.to_integer > 0 and reponse_str.to_integer < 6 and mediatheque.get_utilisateur_connecte.is_admin)
									or (reponse_str.to_integer > 0 and reponse_str.to_integer < 4 and not mediatheque.get_utilisateur_connecte.is_admin) then
									correct := True
									-- Consultation des détails d'un média
									if reponse_str.to_integer = 1 then
										io.put_string("Sur quel média voulez vous plus de détails ? (saisissez son numéro) %N")
										io.flush
										io.read_line
										media.copy(io.last_string)
										if media.is_integer then
											media_int := media.to_integer - 1
											afficher_detail_media(media_int)
										else
											io.put_string("Saissisez le numéro du média %N")
										end
									end
									-- emprunt d'un média
									if reponse_str.to_integer = 2 then 
										io.put_string("Quel média souhaitez vous emprunter? (saississez son numéro) %N")
										io.flush
										io.read_line
										media.copy(io.last_string)
										if media.is_integer then
											media_int := media.to_integer - 1
											mediatheque.get_gestionnaire_emprunt_reservation.emprunter_un_media(media_int)										
										else
											io.put_string("Saissisez le numéro du média %N")
										end
									end
									-- modification d'un média
									if reponse_str.to_integer = 3 and mediatheque.get_utilisateur_connecte.is_admin then 
										io.put_string("Quel média souhaitez vous modifier ? (saississez son numéro) %N")
										io.flush
										io.read_line
										media.copy(io.last_string)
										if media.is_integer then
											media_int := media.to_integer - 1
											modifier_media(media_int)
										else
											io.put_string("Saissisez le numéro du média %N")
										end
									end
									-- suppression d'un média
									if reponse_str.to_integer = 4 and mediatheque.get_utilisateur_connecte.is_admin then 
										io.put_string("Quel media souhaitez vous supprimer ? (saississez son numéro) %N")
										io.flush
										io.read_line
										media.copy(io.last_string)
										if media.is_integer then
											media_int := media.to_integer - 1
											supprimer_media(media_int)
										else
											io.put_string("Saissisez le numéro du média %N")
										end
									end
								else
									if mediatheque.get_utilisateur_connecte.is_admin then
										io.put_string("Veuillez taper soit 1, 2, 3, 4 ou 5")
										io.put_string("%N")
									else
										io.put_string("Veuillez taper soit 1, 2 ou 3")
										io.put_string("%N")
									end
								end -- nombre existant
							else
								io.put_string("Tapez un nombre %N")
							end -- is_integer
						end -- boucle réponse correct
					end
				end
			end
		end
		
	-- Cherche les médias par type
	rechercher_media_par_type (type:STRING):INTEGER is
		do
			-- On remplit la liste media_choisis
			mediatheque.initialiser_liste_medias_choisis
			-- si le type choisi est livre
			if type.is_equal("LIVRE") then
				-- la liste est = à celle des livres
				mediatheque.set_lst_media_choisis(mediatheque.get_lst_livres)
			else
				-- sinon la liste est = à celle des DVD
				mediatheque.set_lst_media_choisis(mediatheque.get_lst_dvd)
			end
			-- on renvoie le nombre d'élément de la liste
			Result := mediatheque.get_lst_media_choisis.count
		end
		
	-- Cherche les médias par titre
	rechercher_media_par_titre (titre: STRING) : INTEGER is
		local
			i: INTEGER
		do
			-- On remplit la liste media_choisis
			mediatheque.initialiser_liste_medias_choisis
			-- on cherche d'abord dans la liste des livres
			from i:=0
			until i = mediatheque.get_lst_livres.count
			loop
				if mediatheque.get_lst_livres.item(i).get_titre.as_lower.has_substring(titre.as_lower) then
					mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_livres.item(i))
				end
				i := i+1
			end
			-- on cherche ensuite dans la liste des dvd
			from i:=0
			until i = mediatheque.get_lst_dvd.count
			loop
				if mediatheque.get_lst_dvd.item(i).get_titre.as_lower.has_substring(titre.as_lower) then
					mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_dvd.item(i))
				end
				i := i+1
			end
			-- on renvoie le nombre d'élément de la liste
			Result := mediatheque.get_lst_media_choisis.count
		end
		
	-- Recherche un média par nom/prenom d'auteur/acteur/réalisateur
	rechercher_media_par_personne (type_personne: STRING; nom_prenom : STRING) : INTEGER is
		local
			i,j : INTEGER
			nom : STRING
			prenom : STRING
		do
			mediatheque.initialiser_liste_medias_choisis
			-- on récupére seulement le nom et le prénom
			nom := nom_prenom.substring(1, nom_prenom.index_of('/',1)-1)
			prenom := nom_prenom.substring(nom_prenom.index_of('/',1)+1, nom_prenom.last_index_of(nom_prenom.last))
			-- Recherche par auteur
			if type_personne.is_equal("AUTEUR") then
				from i:= 0
				until i = mediatheque.get_lst_auteurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if mediatheque.get_lst_auteurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) 
						and mediatheque.get_lst_auteurs.item(i).get_prenom.as_lower.is_equal(prenom.as_lower) then
							-- on récupére tous les livres liés à l'auteur
							from j := 0
							until j = mediatheque.get_lst_auteurs.item(i).get_lst_livres.count
							loop
								mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_auteurs.item(i).get_lst_livres.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if mediatheque.get_lst_auteurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) then
								-- on récupére tous les livres liés à l'auteur
								from j := 0
								until j = mediatheque.get_lst_auteurs.item(i).get_lst_livres.count
								loop
									mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_auteurs.item(i).get_lst_livres.item(j))
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
				until i = mediatheque.get_lst_acteurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if mediatheque.get_lst_acteurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) 
						and mediatheque.get_lst_acteurs.item(i).get_prenom.as_lower.is_equal(prenom.as_lower) then
							-- on récupére tous les dvd liés à l'acteur
							from j := 0
							until j = mediatheque.get_lst_acteurs.item(i).get_lst_films.count
							loop
								mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_acteurs.item(i).get_lst_films.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if mediatheque.get_lst_acteurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) then
								-- on récupére tous les dvd liés à l'acteur
								from j := 0
								until j = mediatheque.get_lst_acteurs.item(i).get_lst_films.count
								loop
									mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_acteurs.item(i).get_lst_films.item(j))
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
				until i = mediatheque.get_lst_realisateurs.count
				loop
					-- Si le nom et le prénom sont renseignés, on test sur les deux
					if prenom.count > 0 and nom.count > 0 then
						if mediatheque.get_lst_realisateurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) 
						and mediatheque.get_lst_realisateurs.item(i).get_prenom.as_lower.is_equal(prenom.as_lower) then
							-- on récupére tous les dvd liés au réalisateur
							from j := 0
							until j = mediatheque.get_lst_realisateurs.item(i).get_lst_films.count
							loop
								mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_realisateurs.item(i).get_lst_films.item(j))
								j := j+1
							end
						end
					else
						-- sinon on test que sur le nom
						if nom.count > 0 then
							if mediatheque.get_lst_realisateurs.item(i).get_nom.as_lower.is_equal(nom.as_lower) then
								-- on récupére tous les dvd liés au réalisateur
								from j := 0
								until j = mediatheque.get_lst_realisateurs.item(i).get_lst_films.count
								loop
									mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_realisateurs.item(i).get_lst_films.item(j))
									j := j+1
								end
							end
						end
					end					
					i:= i+1
				end
			end
			Result := mediatheque.get_lst_media_choisis.count
		end
			
	-- recherche un dvd par année
	rechercher_media_par_annee(annee: INTEGER) : INTEGER is
		local
			i : INTEGER
		do
			mediatheque.initialiser_liste_medias_choisis
			-- on parcourt la liste des dvd
			from i:= 0
			until i = mediatheque.get_lst_dvd.count
			loop
				-- si l'année est égale à celle saisie, on ajoute à la liste
				if mediatheque.get_lst_dvd.item(i).get_annee = annee then
					mediatheque.get_lst_media_choisis.add_last(mediatheque.get_lst_dvd.item(i))
				end
				i := i+1
			end
			Result := mediatheque.get_lst_media_choisis.count
		end

    --afficher menu ajouter media
	ajouter_media is
		local
			choix : STRING
			correct : BOOLEAN
		do
			correct := False
			choix := ""
			from
			until correct
			loop				
				io.put_string("1. Ajouter un DVD %N")
				io.put_string("2. Ajouter un livre %N")
				io.put_string("3. Retour au menu principal %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				
				if choix.is_integer then		
					if choix.to_integer > 0 and choix.to_integer < 4 then
						inspect choix.to_integer
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
				else
					io.put_string("Taper un chiffre%N")
				end
			end -- end loop
		end -- end fonction
		

    --ajouter un dvd   
	ajouter_dvd is
		local
			titre, nom, prenom, type: STRING
			ligne, choix : STRING
			fichier : TEXT_FILE_WRITE
			dvd : DVD
			correct, s_correct: BOOLEAN
			indice : INTEGER
			nb_exemplaires : STRING
			annee : STRING
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
			nb_exemplaires := ""
			annee := ""
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*          AJOUTER DVD         *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")

            -- titre du dvd
			io.put_string("Titre du DVD ? ")
			io.flush
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
			        -- nombre d'exemplaire
				    io.put_string("Nombre d'exemplaires ? ")
				    io.flush
				    io.read_line
				    nb_exemplaires.copy(io.last_string)
				    if nb_exemplaires.is_integer then
						if nb_exemplaires.to_integer >= 0 and nb_exemplaires.to_integer <= 1000 then
						    dvd.set_nombre_exemplaires(nb_exemplaires.to_integer)
							correct := True
						else
							io.put_string("Veuillez taper un nombre")
							io.put_string("%N")
							correct := False
						end
					else	
						io.put_string("Veuillez taper un nombre")
						io.put_string("%N")
				    end
			    end	
			    
			    correct := False
			    from
			    until correct
			    loop
			        -- année de sortie
				    io.put_string("Année de sortie du DVD ? ")
				    io.flush
				    io.read_line
				    annee.copy(io.last_string)
				    if annee.is_integer then
						if annee.to_integer >= 1000 and annee.to_integer <= 9999 then
						    dvd.set_annee(annee.to_integer)
							correct := True
						else
							io.put_string("Veuillez taper une année sur 4 chiffres")
							io.put_string("%N")
							correct := False
						end
					else
						io.put_string("Veuillez taper un nombre")
						io.put_string("%N")
				    end
			    end	
				
				
				-- ajouter des réalisateurs
				correct := False
			    from
			    until correct
			    loop
			        -- demande si ajouter réalisateur
				    io.put_string("Voulez-vous ajouter un/des réalisateurs ? (O/N)")
				    io.flush
			        io.read_line
			        choix.copy(io.last_string)
			        -- si ajout
			        if choix.is_equal("O") then
			            correct := True
				        io.put_string("*** Ajout des réalisateurs *** %N")
				        ajout := True
				        from
				        until not ajout
				        loop
				            create realisateur.make
				            io.put_string("Nom ? ")
				            io.flush
				            io.read_line
				            nom.copy(io.last_string)
				            realisateur.set_nom(nom)
				            io.put_string("Prenom ? ")
				            io.flush
				            io.read_line
				            prenom.copy(io.last_string)
				            realisateur.set_prenom(prenom)
				            dvd.ajouter_realisateur(realisateur)
				            s_correct := False
				            from
				            until s_correct
				            loop
					            io.put_string("Souhaitez vous ajouter un autre réalisateur ? (O/N)")
					            io.flush
					            io.read_line
					            choix.copy(io.last_string)
					            if choix.is_equal("N") then
					                ajout := False
						            s_correct := True
					            else
						            if choix.is_equal("O") then
						                ajout := True
							            s_correct := True
						            else
							            io.put_string("Veuillez taper O pour Oui ou N %
                                              %pour Non")
							            io.put_string("%N")
						            end
					            end
				            end	
                        end
				    elseif choix.is_equal("N") then
				        correct := True
				    else
				        io.put_string("Veuillez taper O pour Oui ou N %
                                              %pour Non")
							            io.put_string("%N")
			        end
			    end -- fin ajouter realisateur
				
				-- ajouter des acteurs
				correct := False
			    from
			    until correct
			    loop
				    io.put_string("Voulez-vous ajouter un/des acteurs ? (O/N)")
				    io.flush
			        io.read_line
			        choix.copy(io.last_string)
			        -- si ajout d'un acteur
			        if choix.is_equal("O") then
			            correct := True
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
				            s_correct := False
				            from
				            until s_correct
				            loop
					            io.put_string("Souhaitez vous ajouter un autre acteur ? (O/N)")
					            io.flush
					            io.read_line
					            choix.copy(io.last_string)
					            if choix.is_equal("N") then
					                ajout := False
						            s_correct := True
					            else
						            if choix.is_equal("O") then
						                ajout := True
							            s_correct := True
						            else
							            io.put_string("Veuillez taper O pour Oui ou N %
                                              %pour Non")
							            io.put_string("%N")
						            end
					            end
				            end	
                        end
				    elseif choix.is_equal("N") then
				        correct := True
				    else
				        io.put_string("Veuillez taper O pour Oui ou N %
                                              %pour Non")
							            io.put_string("%N")
			        end
			    end -- fin ajouter acteur
				
				-- ajout dans les listes
				remplir_lst_realisateurs(dvd)
				remplir_lst_acteurs(dvd)
				
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
				mediatheque.get_lst_dvd.add_last(dvd)
				
			else -- si dvd existe déjà, on propose d'ajouter un exemplaire
				io.put_string("Le média existe déjà.")
				correct := False
				dvd := mediatheque.get_lst_dvd.item(indice)
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
						    mediatheque.get_lst_dvd.item(indice).ajouter_un_exemplaire
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N %
                                  %pour Non")
							io.put_string("%N")
						end
					end
				end
			end -- fin if dvd existe
			
			-- Formatter pour écrire dans le fichier
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
			
			-- écriture du média dans le fichier médias2
			create fichier.make
			fichier.connect_for_appending_to("medias2.txt")
			fichier.put_line(ligne)
			fichier.disconnect
			io.put_string("DVD ajouté !%N")
		end
		
	-- ajouter un livre
	ajouter_livre is
	    local
	    	livre : LIVRE
	    	auteur : AUTEUR
	    	titre, nom, prenom : STRING
	    	nb_exemplaires : STRING
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
			nb_exemplaires := ""
			
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*         AJOUTER LIVRE        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("%N")

            -- titre du livre
			io.put_string("Titre du livre ? ")
			io.flush
			io.read_line
			titre.copy(io.last_string)
			indice := verifier_lst_media(titre)
			
			-- si le livre n'existe pas
			if indice = -1 then
			    create livre.make			    
			    livre.set_titre(titre)
			    
			    -- création de l'auteur
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
			    
			    -- nombre d'exemplaire
			    correct := False
			    from
			    until correct
			    loop
				    io.put_string("Nombre d'exemplaires ? ")
				    io.flush
				    io.read_line
				    nb_exemplaires.copy(io.last_string)
				    if nb_exemplaires.is_integer then
						if nb_exemplaires.to_integer >= 0 and nb_exemplaires.to_integer <= 1000 then
						    livre.set_nombre_exemplaires(nb_exemplaires.to_integer)
							correct := True
						else
							io.put_string("Veuillez taper un nombre")
							io.put_string("%N")
							correct := False
						end
				    else
				    	io.put_string("Veuillez taper un nombre")
						io.put_string("%N")
				    end
			    end
			    -- ajout du livre à la liste
			    mediatheque.get_lst_livres.add_last(livre)
			  
			else -- si livre existe déjà, on propose d'ajouter un exemplaire
				io.put_string("Le média existe déjà.")
				correct := False
				livre := mediatheque.get_lst_livres.item(indice)
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
						    mediatheque.get_lst_livres.item(indice).ajouter_un_exemplaire
							correct := True
						else
							io.put_string("Veuillez taper O pour Oui ou N %
                                  %pour Non")
							io.put_string("%N")
						end
					end
				end
			end -- fin if livre existe
			
			-- formattage pour ajout au fichier
			ligne.append("Livre ; Titre<"+livre.get_titre+"> ; Auteur<"+livre.get_auteur.get_prenom+" "+livre.get_auteur.get_nom+"> ")
			if livre.get_nombre_exemplaires > 1 then
			    ligne.append("; Nombre<"+livre.get_nombre_exemplaires.to_string+">")
			end
			
			-- écriture dans le fichier
			create fichier.make
			fichier.connect_for_appending_to("medias2.txt")
			fichier.put_line(ligne)
			fichier.disconnect
			io.put_string("Livre ajouté !%N")
	    end
	    
	-- afficher la liste de média trouvé dans la recherche
	afficher_media_choisi is
		local
			i, j: INTEGER
		do
			from i:= 0
			until i = mediatheque.get_lst_media_choisis.count
			loop
				j := i+1
				io.put_string("%T "+j.to_string+". ")
				io.put_string(mediatheque.get_lst_media_choisis.item(i).to_string)
				io.put_string("%N")
				i := i+1
			end
		end
		
	-- affiche le détail associé à un média
	afficher_detail_media(choix_media : INTEGER) is
		local
			livre : LIVRE
			dvd : DVD
			i,j : INTEGER
		do
		    -- recherche le média dans la liste
			from i:= 0
			until i = mediatheque.get_lst_media_choisis.count
			loop
				if i = choix_media then
					if mediatheque.get_lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = mediatheque.get_lst_livres.count
						loop
							if mediatheque.get_lst_livres.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								livre := mediatheque.get_lst_livres.item(j)
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = mediatheque.get_lst_dvd.count
						loop
							if mediatheque.get_lst_dvd.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								dvd := mediatheque.get_lst_dvd.item(j)
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
			-- si c'est un livre
			if livre /= Void then
				io.put_string("Titre : "+livre.get_titre)
				io.put_string("%N")
				io.put_string("Auteur : "+livre.get_auteur.get_prenom+" "+livre.get_auteur.get_nom)
				io.put_string("%N")
				io.put_string("Nombre d'exemplaire : ")
				io.put_integer(livre.get_nombre_exemplaires)
				io.put_string("%N")
			else -- si c'est un dvd
				io.put_string("Titre : "+dvd.get_titre)
				io.put_string("%N")
				io.put_string("Année de parution : ")
				io.put_integer(dvd.get_annee)
				io.put_string("%N")
				io.put_string("Nombre d'exemplaire : ")
				io.put_integer(dvd.get_nombre_exemplaires)
				io.put_string("%N")
				if not dvd.get_type.is_empty then
					io.put_string("Type : Coffret %N")
				end
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
	
	-- Fonction récupérant le média choisi et appelant la fonction de modification associée
	modifier_media(choix_media : INTEGER) is
		local
			livre, new_livre : LIVRE
			dvd, new_dvd : DVD
			i,j : INTEGER
		do
		    io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*        MODIFIER MEDIA        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
		    -- on cherche le média dans la liste des médias choisis
			from i:= 0
			until i = mediatheque.get_lst_media_choisis.count
			loop
				if i = choix_media then
					if mediatheque.get_lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = mediatheque.get_lst_livres.count
						loop
							if mediatheque.get_lst_livres.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								livre := mediatheque.get_lst_livres.item(j)
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = mediatheque.get_lst_dvd.count
						loop
							if mediatheque.get_lst_dvd.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								dvd := mediatheque.get_lst_dvd.item(j)
							end
							j := j+1
						end
					end
				end
				i := i+1
			end
			
			-- Si c'est un livre on appelle modifier_livre sinon modifier_dvd
			if livre /= Void then
				new_livre := modifier_livre(livre)
			else
				new_dvd := modifier_dvd(dvd)
			end			
		end
	
	-- Fonction permettant de modifier un livre
	modifier_livre(livre : LIVRE) : LIVRE is
		local
			choix : STRING
			correct : BOOLEAN
		do
			choix := ""
			-- modification du titre
			io.put_string("Titre actuel : "+livre.get_titre+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier titre ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					io.put_string("Nouveau titre : ")
					io.flush
					io.read_line
					livre.set_titre(io.last_string)
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			-- modification de l'auteur
			io.put_string("Auteur actuel : "+livre.get_auteur.get_nom+" "+livre.get_auteur.get_prenom+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier auteur ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					io.put_string("Prénom auteur : ")
					io.flush
					io.read_line
					livre.get_auteur.set_prenom(io.last_string)
					io.put_string("Nom auteur : ")
					io.flush
					io.read_line
					livre.get_auteur.set_nom(io.last_string)
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			-- ajout d'un exemplaire
			io.put_string("Nombre d'exemplaires actuel : "+livre.get_nombre_exemplaires.to_string+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Ajouter un exemplaire ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					livre.ajouter_un_exemplaire
					io.put_string("Nouveau nombre d'exemplaires: "+livre.get_nombre_exemplaires.to_string+"%N")
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			io.put_string("Livre modifié %N")
			Result := livre
		end
		
	-- fonction permettant de modifier un dvd
	modifier_dvd(dvd : DVD) : DVD is
		local
			choix : STRING
			continuer, correct, correct_a : BOOLEAN
			acteur : ACTEUR
			realisateur : REALISATEUR
			annee : STRING
		do
			choix := ""
			annee := ""
			-- modification du titre
			io.put_string("Titre actuel : "+dvd.get_titre+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier titre ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					io.put_string("Nouveau titre : ")
					io.flush
					io.read_line
					dvd.set_titre(io.last_string)
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			--- ajout d'un exemplaire
			io.put_string("Nombre d'exemplaires actuel : "+dvd.get_nombre_exemplaires.to_string+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Ajouter un exemplaire ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					dvd.ajouter_un_exemplaire
					io.put_string("Nouveau nombre d'exemplaires: "+dvd.get_nombre_exemplaires.to_string+"%N")
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			-- modification de l'année
			io.put_string("Année de parution actuelle : "+dvd.get_annee.to_string+"%N")
			correct := False
			from
			until correct
			loop
				io.put_string("Modifier année ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					correct_a := False
					from
					until correct_a
					loop
						io.put_string("Nouvelle année : ")
						io.flush
						io.read_line
						annee.copy(io.last_string)
						if annee.is_integer then
							correct_a := True
							dvd.set_annee(annee.to_integer)
						else	
							io.put_string("Tapez un nombre %N")
						end
					end
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			-- ajout d'un acteur
			correct := False
			from
			until correct
			loop
				io.put_string("Ajouter un acteur ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					continuer := True
					from
					until not continuer
					loop
						create acteur.make
						io.put_string("Prénom acteur : ")
						io.flush
						io.read_line
						acteur.set_prenom(io.last_string)
						io.put_string("Nom acteur : ")
						io.flush
						io.read_line
						acteur.set_nom(io.last_string)
						dvd.ajouter_acteur(acteur)
						correct_a := False
						from
						until correct_a
						loop
							io.put_string("Ajouter un autre acteur ? O/N%N")
							io.flush
							io.read_line
							choix.copy(io.last_string)
							if choix.is_equal("N") then
								continuer := False
								correct_a := True
							elseif choix.is_equal("O") then
								correct_a := True
							else 
								io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
							end
						end
					end
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			-- ajout d'un réalisateur
			correct := False
			from
			until correct
			loop
				io.put_string("Ajouter un réalisateur ? O/N %N")
				io.flush
				io.read_line
				choix.copy(io.last_string)
				if choix.is_equal("O") then
					continuer := True
					from
					until not continuer
					loop
						create realisateur.make
						io.put_string("Prénom réalisateur : ")
						io.flush
						io.read_line
						realisateur.set_prenom(io.last_string)
						io.put_string("Nom réalisateur : ")
						io.flush
						io.read_line
						realisateur.set_nom(io.last_string)
						dvd.ajouter_realisateur(realisateur)
						correct_a := False
						from
						until correct_a
						loop
							io.put_string("Ajouter un autre réalisateur ? O/N%N")
							io.flush
							io.read_line
							choix.copy(io.last_string)
							if choix.is_equal("N") then
								continuer := False
								correct_a := True
							elseif choix.is_equal("O") then
								correct_a := True
							else 
								io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
							end
						end
					end
					correct := True
				elseif choix.is_equal("N") then
					correct := True
				else
					io.put_string("Veuillez taper O pour Oui ou N pour Non %N")
				end
			end
			io.put_string("DVD modifié %N")
			Result := dvd
		end
		
	-- Vérifie si un livre existe déjà, s'il existe renvoie sa position dans la liste
	livre_existe(livre : LIVRE) : INTEGER is
		local
			i, position : INTEGER
		do
			position := -1
			from i:=0
			until i = mediatheque.get_lst_livres.count
			loop
				if mediatheque.get_lst_livres.item(i).get_titre.is_equal(livre.get_titre)
				and mediatheque.get_lst_livres.item(i).get_auteur.get_nom.is_equal(livre.get_auteur.get_nom)
				and mediatheque.get_lst_livres.item(i).get_auteur.get_prenom.is_equal(livre.get_auteur.get_prenom) then
					position := i
				end
				i := i+1
			end
			Result := position
		end
		
	-- Vérifie si un livre existe déjà, s'il existe renvoie sa position dans la liste
	dvd_existe(dvd : DVD) : INTEGER is
		local
			i,position : INTEGER
		do
			position := -1
			from i:=0
			until i = mediatheque.get_lst_dvd.count
			loop
				if mediatheque.get_lst_dvd.item(i).get_titre.is_equal(dvd.get_titre)
				and mediatheque.get_lst_dvd.item(i).get_annee = dvd.get_annee
				and mediatheque.get_lst_dvd.item(i).get_type.is_equal(dvd.get_type) then
					position := i
				end
				i := i+1
			end
			Result := position
		end
		
	-- supprime un média de la liste des médias et du fichier des médias à partir de la position dans la liste des médias 
	supprimer_media(choix_media : INTEGER) is
		local
			livre : LIVRE
			dvd : DVD
			i,j : INTEGER
			position_lst_livre : INTEGER
			position_lst_dvd : INTEGER
			supprime : BOOLEAN
			
		do
			position_lst_livre := -1
			position_lst_dvd := -1
			-- récupère le média correspondant
			from i:= 0
			until i = mediatheque.get_lst_media_choisis.count
			loop
				if i = choix_media then
					if mediatheque.get_lst_media_choisis.item(i).to_string.has_substring("LIVRE") then
						from j:= 0
						until j = mediatheque.get_lst_livres.count
						loop
							if mediatheque.get_lst_livres.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								livre := mediatheque.get_lst_livres.item(j)
								position_lst_livre := j
							end
							j := j+1
						end
					else 
						from j:= 0
						until j = mediatheque.get_lst_dvd.count
						loop
							if mediatheque.get_lst_dvd.item(j).get_titre = mediatheque.get_lst_media_choisis.item(i).get_titre then
								dvd := mediatheque.get_lst_dvd.item(j)
								position_lst_dvd := j
							end
							j := j+1
						end
					end
				end
				i := i+1
			end
			
			-- Si le média trouvé est un livre
			if position_lst_livre > -1 then
				if livre.get_lst_emprunts.count = 0 and livre.get_lst_reservations.count = 0 then
				    -- supprime le livre de la liste et du fichier
					supprime := supprimer_livre_fichier(livre)
					mediatheque.get_lst_livres.remove(position_lst_livre)
					io.put_string("Le livre a été supprimé %N")
				else
					io.put_string("Le livre ne peut pas être supprimé car il est emprunté/réservé %N")
				end
			-- si c'est un dvd
			elseif position_lst_dvd > -1 then
				if dvd.get_lst_emprunts.count = 0 and dvd.get_lst_reservations.count = 0 then
				    -- supprimer du fichier et de la liste des dvd
					supprime := supprimer_dvd_fichier(dvd)				
					mediatheque.get_lst_dvd.remove(position_lst_dvd)
					io.put_string("Le dvd a été supprimé %N")
					
				else
					io.put_string("Le dvd ne peut pas être supprimé car il est emprunté/réservé %N")
				end
			else
				io.put_string("Erreur lors de la suppression")
			end
		end
		
    -- parcours les deux fichiers et supprimer le livre s'il est présent
	supprimer_livre_fichier(livre : LIVRE) : BOOLEAN is
		local
			fichier_r1 : TEXT_FILE_READ
			fichier_r2 : TEXT_FILE_READ
			fichier_w1 : TEXT_FILE_WRITE
			fichier_w2 : TEXT_FILE_WRITE
			tableau_media : ARRAY[STRING]
			ligne : STRING
			supprime : BOOLEAN
			i : INTEGER
		do
			supprime := False
			create fichier_r1.make
			fichier_r1.connect_to("medias.txt")
			-- parcours du premier fichier
			if fichier_r1.is_connected then
				create tableau_media.with_capacity(1,0)
				from
				until fichier_r1.end_of_input
				loop
				    ligne := ""
					fichier_r1.read_line_in(ligne)
					if ligne.has_substring(livre.get_titre) and ligne.has_substring(livre.get_auteur.get_nom) 
						and ligne.has_substring(livre.get_auteur.get_prenom) then
						supprime := True
					else
						tableau_media.add_last(ligne)
					end
				end
				fichier_r1.disconnect
				--réécriture du premier fichier si média trouvé
				if supprime then
					create fichier_w1.make
					fichier_w1.connect_to("medias.txt")
					from i:= 0
					until i = tableau_media.count
					loop
						fichier_w1.put_line(tableau_media.item(i))
						i:= i+1
					end
					fichier_w1.disconnect
				end			
			end
			-- parcours du deuxième fichier
			if not supprime then
				create fichier_r2.make
				fichier_r2.connect_to("medias2.txt")
				if fichier_r2.is_connected then
					create tableau_media.with_capacity(1,0)
					from
					until fichier_r2.end_of_input
					loop
					    ligne := ""
						fichier_r2.read_line_in(ligne)
						if ligne.has_substring(livre.get_titre) and ligne.has_substring(livre.get_auteur.get_nom) 
							and ligne.has_substring(livre.get_auteur.get_prenom) then
							supprime := True
						else
							tableau_media.add_last(ligne)
						end
					end
					fichier_r2.disconnect
					-- réécriture du deuxième fichier si le média est trouvé
					if supprime then
						create fichier_w2.make
						fichier_w2.connect_to("medias2.txt")
						from i:= 0
						until i = tableau_media.count
						loop
							fichier_w2.put_line(tableau_media.item(i))
							i:= i+1
						end
						fichier_w2.disconnect
					end			
				end
			end
			Result := supprime
		end
		
	-- supprime le dvd du fichier s'ile st présent
	supprimer_dvd_fichier(dvd : DVD) : BOOLEAN is
		local
			fichier_r1 : TEXT_FILE_READ
			fichier_r2 : TEXT_FILE_READ
			fichier_w1 : TEXT_FILE_WRITE
			fichier_w2 : TEXT_FILE_WRITE
			tableau_media : ARRAY[STRING]
			ligne : STRING
			supprime: BOOLEAN
			i : INTEGER
		do
		    -- parcours du premier fichier
			supprime := False
			create fichier_r1.make
			fichier_r1.connect_to("medias.txt")
			if fichier_r1.is_connected then
				create tableau_media.with_capacity(1,0)
				from
				until fichier_r1.end_of_input
				loop
					ligne := ""
					fichier_r1.read_line_in(ligne)
					if dvd.get_lst_realisateurs.count > 0 then
					    if ligne.has_substring(dvd.get_titre) and ligne.has_substring(dvd.get_lst_realisateurs.item(0).get_nom) 
						    and ligne.has_substring(dvd.get_lst_realisateurs.item(0).get_prenom) then
						    supprime := True
						end
					else
				        if ligne.has_substring(dvd.get_titre) then
						    supprime := True
						end
					end
					if not supprime then
					    tableau_media.add_last(ligne)
					end
				end
				fichier_r1.disconnect
				-- réécriture du premier fichier sans le dvd si le média est trouvé
				if supprime then
					create fichier_w1.make
					fichier_w1.connect_to("medias.txt")
					from i:= 0
					until i = tableau_media.count
					loop
						fichier_w2.put_line(tableau_media.item(i))
						i:= i+1
					end
					fichier_w1.disconnect
				end			
			end
			-- parcours du deuxième fichier
			if not supprime then
				create fichier_r2.make
				fichier_r2.connect_to("medias2.txt")
				if fichier_r2.is_connected then
					create tableau_media.with_capacity(1,0)
					from
					until fichier_r2.end_of_input
					loop
						ligne := ""
						fichier_r2.read_line_in(ligne)
						if dvd.get_lst_realisateurs.count > 0 then
					        if ligne.has_substring(dvd.get_titre) and ligne.has_substring(dvd.get_lst_realisateurs.item(0).get_nom) 
						        and ligne.has_substring(dvd.get_lst_realisateurs.item(0).get_prenom) then
						        supprime := True
						    end
					    else
				            if ligne.has_substring(dvd.get_titre) then
						        supprime := True
						    end
					    end
					    if not supprime then
					        tableau_media.add_last(ligne)
					    end
					end
					fichier_r2.disconnect
					-- réécriture du deuxième fichier sans le dvd si le média est trouvé
					if supprime then
						create fichier_w2.make
						fichier_w2.connect_to("medias2.txt")
						from i:= 0
						until i = tableau_media.count
						loop
							fichier_w2.put_line(tableau_media.item(i))
							i:= i+1
						end
						fichier_w2.disconnect
					end			
				end
			end
			Result := supprime
		end
    end
