class MEDIATHEQUE

creation{ANY}
	make

feature{}
  	utilisateur_connecte : UTILISATEUR
  	lst_users : ARRAY[UTILISATEUR]
  	lst_medias: ARRAY[MEDIA] -- liste des medias
 	lst_acteurs: ARRAY[ACTEUR] --liste des acteurs
 	lst_realisateurs: ARRAY[REALISATEUR] --liste des réalisateurs
  	lst_auteurs: ARRAY[AUTEUR] -- liste des auteurs
  	lst_livres: ARRAY[LIVRE] -- liste des livres
  	lst_dvd : ARRAY[DVD] -- liste des dvd
  	lst_media_choisis : ARRAY[MEDIA] -- liste des médias à afficher
  	gestionnaire_utilisateur : GESTIONNAIRE_UTILISATEUR
  	gestionnaire_media : GESTIONNAIRE_MEDIA
  	gestionnaire_emprunt_reservation : GESTIONNAIRE_EMPRUNT_RESERVATION

feature{ANY}
	make is
		local
			continuer : BOOLEAN
		do
			create lst_users.with_capacity(1,0)			
			create lst_auteurs.with_capacity(1,0)
			create lst_acteurs.with_capacity(1,0)
			create lst_realisateurs.with_capacity(1,0)
			create lst_livres.with_capacity(1,0)
			create lst_dvd.with_capacity(1,0)
			create lst_media_choisis.with_capacity(1,0)
			create gestionnaire_utilisateur.make(Current)
			create gestionnaire_media.make(Current)
			create gestionnaire_emprunt_reservation.make(Current)
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
					continuer := afficher_menu					
				else
					continuer := False
				end
			end
		end
		
	get_lst_users : ARRAY[UTILISATEUR] is
		do
			Result := lst_users
		end
		
	get_utilisateur_connecte : UTILISATEUR is
		do
			Result := utilisateur_connecte
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
		
	get_gestionnaire_emprunt_reservation : GESTIONNAIRE_EMPRUNT_RESERVATION is
		do
			Result := gestionnaire_emprunt_reservation
		end
		
	set_lst_media_choisis (lst : ARRAY[MEDIA]) is
		do 
			lst_media_choisis := lst
		end

	-- fonction qui permet d'initialiser et remplir les listes
	initialisation is
		do			
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
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*    Liste des utilisateurs    *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_users.count
				loop
					io.put_string(lst_users.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des livres
			if lst.is_equal("LIVRE") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*       Liste des livres       *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_livres.count
				loop
					io.put_string(lst_livres.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des DVD
			if lst.is_equal("DVD") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*         Liste des DVD        *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_dvd.count
				loop
					io.put_string(lst_dvd.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des acteurs
			if lst.is_equal("ACTEUR") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*      Liste des acteurs       *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_acteurs.count
				loop
					io.put_string(lst_acteurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des auteurs
			if lst.is_equal("AUTEUR") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*       Liste des auteurs      *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_auteurs.count
				loop
					io.put_string(lst_auteurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des réalisateurs
			if lst.is_equal("REALISATEUR") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*    Liste des réalisateurs    *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_realisateurs.count
				loop
					io.put_string(lst_realisateurs.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage des médias 
			if lst.is_equal("MEDIA") then
				io.put_string("********************************")
				io.put_string("%N")
				io.put_string("*       Liste des médias       *")
				io.put_string("%N")
				io.put_string("********************************")
				io.put_string("%N")
				from i:= 0
				until i = lst_dvd.count
				loop
					io.put_string(lst_dvd.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
				from i:= 0
				until i = lst_livres.count
				loop
					io.put_string(lst_livres.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
			
			-- Affichage du tableau des médias choisis
			if lst.is_equal("MEDIACHOISIS") then
				from i:= 0
				until i = lst_media_choisis.count
				loop
					io.put_string(lst_media_choisis.item(i).to_string)
					io.put_string("%N")
					i := i+1
				end
			end
		end

	-- Fonction qui affiche le menu		
	afficher_menu : BOOLEAN is
		local
			choix : INTEGER
			continuer: BOOLEAN
		do
			continuer := True
			choix := 0
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*        MENU PRINCIPAL        *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("Que souhaitez vous faire ?")
			io.put_string("%N")
			io.put_string("1. Consultation")
			io.put_string("%N")
			io.put_string("2. Rechercher un média")
			io.put_string("%N")
			io.put_string("3. Gérer mes réservations / mes emprunts")
			io.put_string("%N")			
			if utilisateur_connecte.is_admin then
				io.put_string("4. Consulter la liste des utilisateurs")
				io.put_string("%N")
				io.put_string("5. Modifier les informations d'un utilisateur")
				io.put_string("%N")
				io.put_string("6. Ajouter un utilisateur")
				io.put_string("%N")
				io.put_string("7. Ajouter un média")
				io.put_string("%N")
				io.put_string("8. Gérer les réservations et emprunts des utilisateurs")
				io.put_string("%N")
				io.put_string("9. Déconnexion")
				io.put_string("%N")
			else
				io.put_string("4. Déconnexion")
				io.put_string("%N")
			end
			
			io.flush
			io.read_integer
			-- on récupére ce que l'utilisateur à saisi
			choix := io.last_integer
			
			if not utilisateur_connecte.is_admin then
				if choix > 0 and choix < 5 then
					inspect choix
					when 1 then
						afficher_menu_consultation
					when 2 then
						gestionnaire_media.rechercher_media
					when 3 then
						gestionnaire_emprunt_reservation.gerer_emprunt_reservation
					when 4 then
						io.put_string("Déconnexion")
						io.put_string("%N")
						continuer := False
					end
				else
					io.put_string("Veuillez choisir un chiffre entre 1 et 4")
					io.put_string("%N")
				end
			elseif utilisateur_connecte.is_admin then
				if choix > 0 and choix < 10 then
					inspect choix
					when 1 then
						afficher_menu_consultation
					when 2 then
						gestionnaire_media.rechercher_media
					when 3 then
						gestionnaire_emprunt_reservation.gerer_emprunt_reservation
					when 4 then
						afficher_tableau("USER")
						io.put_string("%N")
					when 5 then
						io.put_string("En cours de développement...")
						io.put_string("%N")
					when 6 then
						gestionnaire_utilisateur.ajouter_utilisateur
						io.put_string("%N")
					when 7 then
						gestionnaire_media.ajouter_media
					when 8 then
						gestionnaire_emprunt_reservation.gerer_emprunts_reservations_admin
					when 9 then
						io.put_string("Déconnexion")
						io.put_string("%N")
						continuer := False
					end
				else
					io.put_string("Veuillez choisir un chiffre entre 1 et 9")
					io.put_string("%N")
				end
			end
			
			Result := continuer
		end
		
	afficher_menu_consultation is
		local
			choix : INTEGER
			continuer : BOOLEAN
		do		
			choix := 0
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*       MENU CONSULTATION      *")
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("Que souhaitez vous faire ?")
			io.put_string("%N")
			io.put_string("1. Consulter la liste des médias")
			io.put_string("%N")
			io.put_string("2. Consulter la liste des livres")
			io.put_string("%N")
			io.put_string("3. Consulter la liste des auteurs")
			io.put_string("%N")
			io.put_string("4. Consulter la liste des DVD")
			io.put_string("%N")
			io.put_string("5. Consulter la liste des acteurs")
			io.put_string("%N")
			io.put_string("6. Consulter la liste des réalisateurs")
			io.put_string("%N")
			io.put_string("7. Retour ")
			io.put_string("%N")
			
			io.flush
			io.read_integer
			-- on récupére ce que l'utilisateur à saisi
			choix := io.last_integer
			
			if choix > 0 and choix < 8 then
				inspect choix
				when 1 then
					afficher_tableau("MEDIA")
					io.put_string("%N")
				when 2 then
					afficher_tableau("LIVRE")
					io.put_string("%N")
				when 3 then
					afficher_tableau("AUTEUR")
					io.put_string("%N")
				when 4 then
					afficher_tableau("DVD")
					io.put_string("%N")
				when 5 then 
					afficher_tableau("ACTEUR")
					io.put_string("%N")
				when 6 then
					afficher_tableau("REALISATEUR")
					io.put_string("%N")
				when 7 then 
					continuer := afficher_menu
				else
					io.put_string("Vous n'êtes pas autorisé à exécuter cette action.")
					io.put_string("%N")
				end
			else
				io.put_string("Veuillez choisir un chiffre entre 1 et 7")
				io.put_string("%N")
			end	
		end	
	
	-- Fonctino effectuant la connexion d'un utilisateur
	connexion is
		local 
			identifiant : STRING
			compteur : INTEGER
			connexion_ok : BOOLEAN
		do
			connexion_ok := False
			identifiant := ""
			
			io.put_string("%N")
			io.put_string("********************************")
			io.put_string("%N")
			io.put_string("*           CONNEXION          *")
			io.put_string("%N")
			io.put_string("********************************")
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
					gestionnaire_emprunt_reservation.remplir_lst_reservations
					gestionnaire_emprunt_reservation.remplir_lst_emprunts
					connexion_ok := True
				else
					io.put_string("L'identifiant saisi n'est pas reconnu")
					io.put_string("%N")
				end
				compteur := compteur + 1
			end
			
			if connexion_ok then
				io.put_string("Bienvenue "+utilisateur_connecte.get_prenom+" ! ")
				io.put_string("%N")
			else
				io.put_string("%N")
				io.put_string("Vous avez utilisez vos 3 essais, vous ne pouvez pas vous connecter.")
				io.put_string("%N")
			end
		end
		
	initialiser_liste_medias_choisis is
		do
			create lst_media_choisis.with_capacity(1,0)
		end	
end
