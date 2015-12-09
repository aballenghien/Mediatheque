class MEDIATHEQUE

creation{ANY}
	make

feature{}
  	utilisateur_connecte : UTILISATEUR
  	gestionnaire_utilisateur : GESTIONNAIRE_UTILISATEUR
  	gestionnaire_media : GESTIONNAIRE_MEDIA

feature{ANY}
	make is
		local
			continuer : BOOLEAN
			choix : STRING
			correct : BOOLEAN
		do
			create gestionnaire_utilisateur.make
			create gestionnaire_media.make
			-- on affiche le menu tant que l'utilisateur n'a pas décidé 
			-- de quitter
			continuer := True
			-- remplissage des listes
			initialisation
			-- connexion de l'utilisateur, instanciation de la variable utilisateur_connecte
			connexion
			from
			until not continuer
			loop
				-- si un utilisateur est connecté
				if utilisateur_connecte /= Void then
					-- on affiche le menu
					afficher_menu(utilisateur_connecte)
					correct := False
					choix := ""
					from
					until correct
					loop
						io.put_string("Retour au menu principal ? O/N (N = déconnexion)")
						io.put_string("%N")
						io.flush
						io.read_line
						choix.copy(io.last_string)
						choix.to_upper
						if choix.is_equal("O") or choix.is_equal("N") then
							correct := True
							if choix.is_equal("O") then
								continuer := True
							else 
								continuer := False
							end
						else
							io.put_string("Retour au menu principal ? O/N (N = déconnexion)")
							io.put_string("%N")
						end
					end
				else
					continuer := False
				end
			end
		end

	-- fonction qui permet d'initialiser et remplir les listes
	initialisation is
		do
			-- initilisation des listes
			
			-- remplissage des listes
			gestionnaire_utilisateur.remplir_lst_users
			gestionnaire_media.remplir_lst_medias
			gestionnaire_media.remplir_lst_auteurs_realisateurs_acteurs
		end
						
	-- fonction permettant d'afficher les tableaux
	afficher_tableau (lst : STRING) is
		local
			i :INTEGER
		do
			-- Affichage du tableau des utilisateurs
			if lst.is_equal("USER") then
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_utilisateur.get_lst_users.count
				loop
					io.put_string(gestionnaire_utilisateur.get_lst_users.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des livres
			if lst.is_equal("LIVRE") then
				io.put_string("Affichage des livres : ")
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_media.get_lst_livres.count
				loop
					io.put_string(gestionnaire_media.get_lst_livres.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Afficheage du tableau des DVD
			if lst.is_equal("DVD") then
				io.put_string("Affichage des DVD : ")
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_media.get_lst_dvd.count
				loop
					io.put_string(gestionnaire_media.get_lst_dvd.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des acteurs
			if lst.is_equal("ACTEUR") then
				io.put_string("Affichage des acteurs : ")
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_media.get_lst_acteurs.count
				loop
					io.put_string(gestionnaire_media.get_lst_acteurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des auteurs
			if lst.is_equal("AUTEUR") then
				io.put_string("Affichage des auteurs : ")
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_media.get_lst_auteurs.count
				loop
					io.put_string(gestionnaire_media.get_lst_auteurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des réalisateurs
			if lst.is_equal("REALISATEUR") then
				io.put_string("Affichage des realisateurs : ")
				io.put_string("%N")
				from i:= 0
				until i = gestionnaire_media.get_lst_realisateurs.count
				loop
					io.put_string(gestionnaire_media.get_lst_realisateurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des médias choisis
			if lst.is_equal("MEDIACHOISIS") then
				from i:= 0
				until i = gestionnaire_media.get_lst_media_choisis.count
				loop
					io.put_string(gestionnaire_media.get_lst_media_choisis.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
		end

	-- Fonction qui affiche le menu		
	afficher_menu (un_utilisateur: UTILISATEUR) is
		local
			choix : STRING
		do
			choix := ""
			io.put_string("Que souhaitez vous faire ?")
			io.put_string("%N")
			io.put_string("1. Consulter la liste des médias")
			io.put_string("%N")
			io.put_string("2. Rechercher un média")
			io.put_string("%N")
			io.put_string("3. Gérer mes réservations / mes emprunts")
			io.put_string("%N")
			
			if un_utilisateur.is_admin then
				io.put_string("4. Consulter la liste des utilisateurs")
				io.put_string("%N")
				io.put_string("5. Modifier les informations d'un utilisateur")
				io.put_string("%N")
				io.put_string("6. Ajouter un utilisateur")
				io.put_string("%N")
				io.put_string("7. Ajouter un média")
				io.put_string("%N")
			end
			
			io.flush
			io.read_line
			-- on récupére ce que l'utilisateur à saisi
			choix.copy(io.last_string)
			if choix.is_integer then
				if choix.to_integer = 1 then
					afficher_tableau("LIVRE")
					afficher_tableau("DVD")
					--io.put_string("En cours de développement...")
					io.put_string("%N")
				else
					if choix.to_integer = 2 then
						gestionnaire_media.rechercher_media
					else
						if choix.to_integer = 3 then
							io.put_string("En cours de développement...")
							io.put_string("%N")
						else
							if un_utilisateur.is_admin then
								if choix.to_integer = 4 then
									afficher_tableau("USER")
									--io.put_string("En cours de développement...")
									io.put_string("%N")
								else
									if choix.to_integer = 5 then
										io.put_string("En cours de développement...")
										io.put_string("%N")
									else
										if choix.to_integer = 6 then
											gestionnaire_utilisateur.ajouter_utilisateur
											io.put_string("%N")
										else
											if choix.to_integer = 7 then
												io.put_string("En cours de développement...")
												io.put_string("%N")
											end
										end
									end
								end
							else
								io.put_string("Vous n'êtes pas autorisé à exécuter cette action.")
								io.put_string("%N")
							end
						end
					end
				end
			else
				io.put_string("Veuillez choisir un chiffre entre 1 et 7")
				io.put_string("%N")
			end
		end
		
	-- Fonctino effectuant la connextion d'un utilisateur
	connexion is
		local 
			identifiant : STRING
			mot_de_passe : STRING
			compteur : INTEGER
			connexion_ok : BOOLEAN
		do
			connexion_ok := False
			identifiant := ""
			mot_de_passe := ""
			io.put_string("*** CONNEXION ***")
			io.put_string("%N")
			-- l'utilisateur à 3 essais pour ce connecter
			from compteur := 0
			until compteur = 3 or connexion_ok
			loop
				io.put_string("%N")
				io.put_string("Veuillez entrer votre identifiant : ")
				io.flush
				io.read_line
				identifiant.copy(io.last_string)
				-- on vérifie que l'utilisateur existe
				utilisateur_connecte := gestionnaire_utilisateur.rechercher_utilisateur(identifiant)
				if utilisateur_connecte /=Void then
					connexion_ok := True
				--	io.put_string("Mot de passe pour "+identifiant +":")
				--	io.flush
				--	io.read_line
				--	mot_de_passe.copy(io.last_string)
				--	if mot_de_passe.is_equal("test") then
				--		connexion_ok := True
				--	else
				--		io.put_string("Mot de passe invalide")
				--		io.put_string("%N")
				--	end
				else
					io.put_string("Identifiant non reconnu")
					io.put_string("%N")
				end
				compteur := compteur + 1
			end
			
			if connexion_ok then
				io.put_string("Bienvenue "+utilisateur_connecte.get_prenom+" ! ")
				io.put_string("%N")
				afficher_menu(utilisateur_connecte)
			else
				io.put_string("%N")
				io.put_string("Vous avez utilisez vos 3 essais. Votre compte a été bloqué, veuillez contacter un administrateur de la médiathèque pour pouvoir vous reconnecter")
				io.put_string("%N")
			end
		end
end
