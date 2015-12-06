class LIVRE inherit
	MEDIA
	rename make as make_media
	redefine to_string
	end

creation{ANY}
	make

feature{}
	auteur: AUTEUR
feature {ANY}
	make is 
		do
			make_media
			create auteur.make
		end
			
	set_auteur (a: AUTEUR) is
		do
			auteur:= a
		end
	
	get_auteur : AUTEUR is
		do
			Result:= auteur
		end
		
	to_string : STRING is
		do
			Result := "LIVRE: "+titre
		end
end
