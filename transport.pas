program transport;

const
	nmax=3;
	vide=-9999;

type
	cellule=record
		quantite,prix,indice,signe:integer
	end;
	tableau=array[1..nmax,1..nmax] of cellule;
	vecteur=array[1..nmax] of integer;
	matrice=array[1..nmax,1..nmax] of integer;
	couple=record
		ligne,colonne,signe:integer
	end;
	chemin=record
		graphe:array[1..nmax*nmax] of couple;
		longueur:integer
	end;
	

var
	t:tableau;
	x,y:integer;
	exp,rec,row,col:vecteur;
	chem:chemin;
	
	

(*création et affichage des structures*)



(*création*)
procedure creer_tableau(var t:tableau);
var
	i,j:integer;
begin
	for i:=1 to nmax do
	for j:=1 to nmax do
	begin
		t[i,j].quantite:=0;
		t[i,j].prix:=0;
		t[i,j].indice:=vide
	end
end;

procedure creer_vecteur(var v:vecteur);
var
	i:integer;
begin
	for i:=1 to nmax do v[i]:=vide
end;


(*affichage*)
procedure afficher_tableau(t:tableau);
var
	i,j:integer;
begin
	for i:=1 to nmax do
	begin
		for j:=1 to nmax do write(t[i,j].quantite,'  ',t[i,j].prix,'   ',t[i,j].indice,'         ');
		writeln
	end
end;

procedure afficher_vecteur(v:vecteur);
var
	i:integer;
begin
	for i:=1 to nmax do write(v[i],'   ');
	writeln
end;		 

procedure afficher_matrice(m:matrice);
var
	i,j:integer;
begin
	for i:=1 to nmax do
	begin
		for j:=1 to nmax do write(m[i,j],'   ');
		writeln
	end
end;



(*exemple*)
procedure remplir_exemple(var t:tableau);
(*création du tableau de l'exemple employé*)
begin
	creer_tableau(t);
	t[1,1].quantite:=0;
	t[1,1].prix:=5;
	t[1,2].quantite:=0;
	t[1,2].prix:=4;
	t[1,3].quantite:=0;
	t[1,3].prix:=3;
	t[2,1].quantite:=0;
	t[2,1].prix:=8;
	t[2,2].quantite:=0;
	t[2,2].prix:=4;
	t[2,3].quantite:=0;
	t[2,3].prix:=3;
	t[3,1].quantite:=0;
	t[3,1].prix:=9;
	t[3,2].quantite:=0;
	t[3,2].prix:=7;
	t[3,3].quantite:=0;
	t[3,3].prix:=5;
end;

procedure remplir_exemple_2(var exp,rec:vecteur);
begin
	exp[1]:=300;
	exp[2]:=200;
	exp[3]:=200;
	rec[1]:=100;
	rec[2]:=300;
	rec[3]:=300
end;

(*prise d'information*)
procedure remplir_prix(var t:tableau);
var
	i,j,n:integer;
begin
	writeln('prix des déplacements par pièce');
	for i:=1 to nmax do
	for j:=1 to nmax do
	begin
		writeln('prix entre l''expéditeur ',j,' et l''entreprise ',i);
		readln(n);
	 	t[i,j].prix:=n;
	 	t[i,j].indice:=vide
	end
end;

procedure remplir_quantite(var t:tableau;var exp,rec:vecteur);
var
	i,n:integer;
begin
writeln('nombre de pièces en stock chez chaque expéditeur:');
	for i:=1 to nmax do
	begin
		writeln('expéditeur ',i);
		readln(n);
		exp[i]:=n
	end;
	writeln('nombre de pièces que peut recevoir chaque entreprise:');
	for i:=1 to nmax do
	begin
		writeln('récéption ',i);
		readln(n);
		rec[i]:=n
	end
end;




//MÉTHODE 1




(*remplissage du coin nord-est*)



(*application de la méthode du coin nord-est par récurrence*)
procedure coin_ne(var t:tableau;x,y:integer;var exp,rec:vecteur);
var
	sexp,i:integer;
begin
	sexp:=0;
	for i:=1 to nmax do sexp:=sexp+exp[i];
	if sexp <> 0 then
	begin
		if exp[y]<rec[x] then 
		begin
			t[x,y].quantite:=t[x,y].quantite+exp[y];
			rec[x]:=rec[x]-exp[y];
			exp[y]:=0;
			coin_ne(t,x,y+1,exp,rec)
		end
		else
		begin
			t[x,y].quantite:=t[x,y].quantite+rec[x];
			exp[y]:=exp[y]-rec[x];
			rec[x]:=0;
			if exp[y]<>0 then coin_ne(t,x+1,y,exp,rec) else coin_ne(t,x+1,y+1,exp,rec)
		end
	end
end;

procedure remplir_coin_ne(var t:tableau;exp,rec:vecteur);
var
	i,j,n:integer;
begin
(*remplissage du tableau par la méthode du coin nord-est*)
	for i:=1 to nmax do for j:=1 to nmax do t[i,j].quantite:=0;
	coin_ne(t,1,1,exp,rec);
end;



(*recherche de la solution optimale*)



(*calcul des indices pour remplir le tableau*)	
procedure calculer_indice(var t:tableau);
var
	v1,v2:vecteur;
	m1:matrice;
	i,j,k:integer;
begin
	for i:=1 to nmax do
	for j:=1 to nmax do t[i,j].indice:=vide;
	creer_vecteur(v1);
	creer_vecteur(v2);
(*les vecteurs vont servir à contenir les coefficients assignés aux colonnes (Ri) et aux lignes (Ki)*)
(*on remplit une matrice avec les prix des liaisons utiles*)
	for i:=1 to nmax do
	for j:=1 to nmax do
		if t[i,j].quantite <> 0 then
		begin
			m1[i,j]:=t[i,j].prix;
			t[i,j].indice:=0
			end
		else m1[i,j]:=vide;
	v1[1]:=0; (*par convention R1=0*)
(*on résoud le système d'équations pour trouver les coefficients des lignes et colonnes moyennant certaines hypothèses:
	-le determinant du systeme est non nul
	-toutes les équations sont de la forme Ri+Kj=prix
ces hypothèses ne semblent pas être trop contraignantes au modèle*)
	for k:=1 to nmax do
	begin
		for i:=1 to nmax do
			if v1[i]<>vide then
			for j:=1 to nmax do 
				if m1[i,j] <> vide then	v2[j]:=m1[i,j]-v1[i];
		for i:=1 to nmax do
			if v2[i]<>vide then
			for j:=1 to nmax do 
				if m1[j,i] <> vide then v1[j]:=m1[j,i]-v2[i];
	end;
(*il ne reste plus qu'à ajouter les indices au tableau*)
	for i:=1 to nmax do
	for j:=1 to nmax do
	if t[i,j].indice=vide then t[i,j].indice:=t[i,j].prix-v1[i]-v2[j];
end;

(*si un des indices est négatif, la solution n'est pas optimale
il faut donc tester si l'un des indices est négatif*)
function test_indice_neg(t:tableau;var x,y:integer):boolean;
(*x (ou y) est la ligne (ou la colonne) de la cellule du tableau possédant un indice négatif*)
var
	i,j:integer;
	test:boolean;
begin
	for i:=1 to nmax do
	for j:=1 to nmax do
	if t[i,j].indice<0 then
	begin
		x:=i;
		y:=j;
		test:=false
	end;
	if test=true then test_indice_neg:=true else test_indice_neg:=false
end;

(*construction du chemin en cas d'indice négatif*)
// la méthode algorithmique de la construction du chemin parrait trop délicate

(*recherche du minimum des quantités (-)*)
procedure restriction(c:chemin;var rest:chemin);
var
	i:integer;
begin
	i:=1;
	rest.longueur:=0;
	while c.longueur>2*i do 
	begin
		rest.graphe[i]:=c.graphe[2*i];
		rest.longueur:=rest.longueur+1
	end
end;

function minimum_chem(c:chemin;t:tableau;n:integer):integer;
var
	aux:integer;
	rest:chemin;
begin
	restriction(c,rest);
	if n=rest.longueur then minimum_chem:=t[rest.graphe[n].ligne,rest.graphe[n].colonne].quantite else
	begin
		aux:=minimum_chem(rest,t,n+1);
		if aux<t[rest.graphe[n].ligne,rest.graphe[n].colonne].quantite then minimum_chem:=aux else minimum_chem:=t[rest.graphe[n].ligne,rest.graphe[n].colonne].quantite
	end
end;

(*modifier les quantités du tableau en fonction du chemin*)
procedure modif_quantite(var t:tableau;c:chemin);
var
	min,i:integer;
	r:chemin;
begin
	restriction(c,r);
	min:=minimum_chem(r,t,1);
	for i:=1 to c.longueur div 2 do
	begin
		t[c.graphe[2*i].ligne,c.graphe[2*i].colonne].quantite:=t[c.graphe[2*i].ligne,c.graphe[2*i].colonne].quantite + min;
		t[c.graphe[2*i-1].ligne,c.graphe[2*i-1].colonne].quantite:=t[c.graphe[2*i-1].ligne,c.graphe[2*i-1].colonne].quantite - min
	end
end;


(*recherche du tableau optimal*)
procedure optimal_1(var t:tableau;exp,rec:vecteur;var c:chemin);
var
	x,y:integer;
begin
	calculer_indice(t);
	while not test_indice_neg(t,x,y) do
	begin
//		creer_chemin(t,x,y,c);
		modif_quantite(t,c);
		calculer_indice(t)
	end;
	afficher_tableau(t)
end;



//MÉTHODE 2


(*recherche de la solution optimale directe*)


(*fonctions donnant les valeurs maximale et minimale d'un vecteur*)	
function min_vect(v:vecteur):integer;
var
	i,x:integer;
begin
	i:=1;
	while v[i]=vide do i:=i+1;
	x:=v[i];
	for i:=i+1 to nmax do if v[i]<>vide then if v[i]<x then x:=v[i];
	min_vect:=x
end;

function max_vect(v:vecteur;var place:integer):integer;
var
	i,j,x:integer;
begin
	i:=1;
	while ((v[i]=vide) and (i<nmax)) do i:=i+1;
	x:=v[i];
	place:=i;
	for j:=i+1 to nmax do if v[j]<>vide then if v[j]>x then
	begin
		x:=v[j];
		place:=j
	end;
	max_vect:=x
end;

(*calculer indice*)

function case_non_vide_vect(v:vecteur):integer;
var
	i,j:integer;
begin
	i:=0;
	for j:=1 to nmax do if v[j]<>vide then i:=i+1;
	case_non_vide_vect:=i
end;

procedure calculer_indice_2_first(t:tableau;var row,col:vecteur);
var
	n,x,y,i,j:integer;
begin
(*remplissage de row*)
	for i:=1 to nmax do
	begin
		if t[i,1].prix<t[i,2].prix then
		begin
			x:=t[i,1].prix;
			y:=t[i,2].prix
		end
		else
		begin
			x:=t[i,2].prix;
			y:=t[i,1].prix
		end;
		for j:=3 to nmax do
		begin
			if t[i,j].prix<y then
			if t[i,j].prix<x then
			begin
				y:=x;
				x:=t[i,j].prix
			end
			else y:=t[i,j].prix
		end;
		row[i]:=y-x
	end;
(*remplissage de col*)
	for j:=1 to nmax do
	begin
		if t[1,j].prix<t[2,j].prix then
		begin
			x:=t[1,j].prix;
			y:=t[2,j].prix
		end
		else
		begin
			x:=t[2,j].prix;
			y:=t[1,j].prix
		end;
		for i:=3 to nmax do
		begin
			if t[i,j].prix<y then
			if t[i,j].prix<x then
			begin
				y:=x;
				x:=t[i,j].prix
			end
			else y:=t[i,j].prix
		end;
		col[j]:=y-x
	end
end;

procedure calculer_indice_2_next(t:tableau;var row,col:vecteur);
var
	n,x,y,i,j:integer;
	excol,exrow:vecteur;
begin
	excol:=col;
	exrow:=row;
(*remplissage de row*)
	n:=case_non_vide_vect(col);
	if ((n=0) or (n=1)) then for i:=1 to nmax do row[i]:=vide
	else
	begin
		for i:=1 to nmax do
		if row[i]<>vide then
		begin
			j:=1;
			while t[i,j].quantite<>0 do j:=j+1;
			x:=t[i,j].prix;
			j:=j+1;
			while t[i,j].quantite<>0 do j:=j+1;
			if t[i,j].prix<x then
			begin
				y:=x;
				x:=t[i,j].prix
			end
			else y:=t[i,j].prix;
			for j:=j+1 to nmax do
			begin
				if t[i,j].prix<y then
				if t[i,j].prix<x then
				begin
					y:=x;
					x:=t[i,j].prix
				end
				else y:=t[i,j].prix
			end;
			row[i]:=y-x
		end
	end;	
(*remplissage de col*)
	n:=case_non_vide_vect(exrow);
	if ((n=0) or (n=1)) then for j:=1 to nmax do col[j]:=vide
	else
	begin
		for j:=1 to nmax do
		if col[j]<>vide then
		begin
			i:=1;
			while t[i,j].quantite<>0 do i:=i+1;
			x:=t[i,j].prix;
			i:=i+1;
			while t[i,j].quantite<>0 do i:=i+1;
			if t[i,j].prix<x then
			begin
				y:=x;
				x:=t[i,j].prix
			end
			else y:=t[i,j].prix;
			for i:=i+1 to nmax do
			begin
				if t[i,j].prix<y then
				if t[i,j].prix<x then
				begin
					y:=x;
					x:=t[i,j].prix
				end
				else y:=t[i,j].prix
			end;
			col[j]:=y-x
		end
	end
end;	
		

(*remplissage du tableau en fonction des indices*)
procedure remplir_tableau(var t:tableau;var row,col,exp,rec:vecteur);
var
	x,y,i,j,min,maxx,maxy,place:integer;
begin
	maxx:=max_vect(row,x);
	maxy:=max_vect(col,y);
	if ((maxx=vide) and (maxy=vide)) then
	begin	
		for i:=1 to nmax do
		for j:=1 to nmax do
		begin
			if t[i,j].quantite=0 then
			begin
				t[i,j].quantite:=rec[i];
				exp[j]:=exp[j]-rec[i];
				rec[i]:=0;
				col[i]:=vide
			end
		end
	end
	else
	if maxy=vide then
	begin
		for i:=1 to nmax do
		for j:=1 to nmax do
		begin
			if t[i,j].quantite=0 then
			begin
				t[i,j].quantite:=exp[j];
				rec[i]:=rec[i]-exp[j];
				exp[j]:=0;
				row[j]:=vide
			end
		end
	end
	else
	if maxx>maxy then
	begin
		j:=1;
		while t[x,j].quantite<>0 do j:=j+1;
		min:=t[x,j].prix;
		place:=j;
		for j:=j+1 to nmax do
			if ((t[x,j].quantite=0) and (t[x,j].prix<min)) then
			begin
				min:=t[x,j].prix;
				place:=j
			end;
		if exp[place]<rec[x] then
		begin
			rec[x]:=rec[x]-exp[place];
			t[x,place].quantite:=exp[place];
			exp[place]:=0;
			for i:=1 to nmax do if t[i,place].quantite=0 then t[i,place].quantite:=vide;
			col[place]:=vide
		end
		else
		begin
			exp[place]:=exp[place]-rec[x];
			t[x,place].quantite:=rec[x];
			rec[x]:=0;
			for j:=1 to nmax do if t[x,j].quantite=0 then t[x,j].quantite:=vide;
			row[x]:=vide
		end
	end
	else
	begin
		i:=1;
		while t[i,y].quantite<>0 do i:=i+1;
		min:=t[i,y].prix;
		place:=i; 
		for i:=i+1 to nmax do
			if ((t[i,y].quantite=0) and (t[i,y].prix<min)) then
			begin
				min:=t[i,y].prix;
				place:=i
			end;
		if rec[place]<exp[y] then
		begin

			exp[y]:=exp[y]-rec[place];
			t[place,y].quantite:=rec[place];
			rec[place]:=0;
			for j:=1 to nmax do if t[place,j].quantite=0 then t[place,j].quantite:=vide;
			row[place]:=vide
		end
		else
		begin
			rec[place]:=rec[place]-exp[y];
			t[place,y].quantite:=exp[y];
			exp[y]:=0;
			for i:=1 to nmax do if t[i,y].quantite=0 then t[i,y].quantite:=vide;
			col[y]:=vide		
		end
	end
end;

(*fonction testant s'il reste des quantité à zéro dans le tableau, preuve que la solution n'est pas optimale*)
function test_quantite_zero(t:tableau):boolean;
var
	i,j:integer;
	test:boolean;
begin
	test:=true;
	for i:=1 to nmax do
	for j:=1 to nmax do
	if t[i,j].quantite=0 then test:=false;
	test_quantite_zero:=test
end;


(*recherche du tableau optimal*)
procedure optimal_2(var t:tableau;exp,rec:vecteur);
var
	row,col:vecteur;
	i,j:integer;
begin
	calculer_indice_2_first(t,row,col);
	remplir_tableau(t,row,col,exp,rec);
	while not test_quantite_zero(t) do
	begin
		calculer_indice_2_next(t,row,col);
		remplir_tableau(t,row,col,exp,rec)
	end;
	for i:=1 to nmax do
	for j:=1 to nmax do
		if t[i,j].quantite=vide then t[i,j].quantite:=0;
	afficher_tableau(t)
end;
	



BEGIN
	creer_tableau(t);
	remplir_prix(t);
	remplir_quantite(t,exp,rec);
	optimal_1(t,exp,rec,chem);
	optimal_2(t,exp,rec);
END.
