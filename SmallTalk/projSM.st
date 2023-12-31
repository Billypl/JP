"Student nr1: Michał Pawiłojć, 193159"
"Student nr2: Hanna Banasiak, 193078"

"https://www.jdoodle.com/execute-smalltalk-online/"

Object subclass: #Wielokat
	instanceVariableNames: 'wierzcholki nazwa Srodek'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JezykiProgramowania'!

    !Wielokat methodsFor: 'initialize-release'!
    
        initialize: liczbaWierzcholkow name: nowaNazwa
        	"konstruktor obiektu - wielokata"
        
        	nazwa:=nowaNazwa.
        	wierzcholki:=Array new: liczbaWierzcholkow.
        	wierzcholki at: 1 put: 0@0.
        	
        ! 
    !
    
    !Wielokat methodsFor: 'accessing'!
        nazwa
        	"podaje nazwe wielokata"
        	^nazwa
        !
        nazwa: nowa_nazwa
        	"ustawia nowa nazwe wielokata"
        	nazwa:=nowa_nazwa
        ! 
    !
    
    !Wielokat methodsFor: 'actions'!
        pole 
            ^0
        !
        
        drukuj        
            Transcript show: 'To jest ', nazwa; cr.
            "petla z wierzcholkami"
            wierzcholki do: 
            [:wierzcholek | 
                | index |
                index := wierzcholki indexOf: wierzcholek.
                Transcript show: '  Wierzcholek ', index printString, ': ', wierzcholek printString; cr.
                
            ].
            Transcript show: '  Srodek: ', Srodek printString; cr.
            Transcript show: '  Pole = ', self pole printString; cr.
            Transcript cr.
        !   
        wysrodkuj
            Transcript show: '### Wysrodkowano figure ', self nazwa, ' (srodek figury znajdowal się w punkcie ', Srodek printString,')'; cr; cr.
        !
        + figura
        	Transcript show: '### Dodano pole figury ', self nazwa, ' (pole = ', self pole printString, ')' , ' oraz figury ', figura nazwa, ' (pole = ', figura pole printString, ')'; cr; cr.
        !
        
    !




Wielokat subclass: #Kwadrat
	instanceVariableNames: 'Bok'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JezykiProgramowania'!

    !Kwadrat methodsFor: 'initialize-release'!

        initialize: srodek and: bok
        	"tworz kwadrat o podanym boku"
        
        	super initialize: 4 name: 'Kwadrat'.
        	wierzcholki at: 2 put: bok@0.
        	wierzcholki at: 3 put: bok@bok.
        	wierzcholki at: 4 put: 0@bok.
        	
        	"przesuniecie do srodka ukladu wpolrzednych"
        	1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x - (1/2 * bok))@((wierzcholki at: index) y - (1/2 * bok)).
            ].
        	
        	"przesuniecie o srodek"
            1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x + srodek x)@((wierzcholki at: index) y + srodek y).
            ].
            
            Srodek := srodek.
            Bok := bok.
        ! 
        initialize: bok 
            self initialize: (1/2*bok)@(1/2*bok) and: bok
        !
    !

    !Kwadrat methodsFor: 'arithmetic'!
        + figura
        	"dodaj 2 figury w sensie pola"
        	| p |
        	p:=self pole + figura pole.
        	super + figura.
        	^(Kwadrat new) initialize: Srodek and: p sqrt
        !
    !
    
    !Kwadrat methodsFor: 'actions'!
        pole
        	"licz pole kwadratu"
        	^Bok squared
        !
        wysrodkuj
            super wysrodkuj.
            self initialize: 0@0 and: Bok
        !
    !    
        
Wielokat subclass: #Szesciokat
	instanceVariableNames: 'Bok'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JezykiProgramowania'!

    !Szesciokat methodsFor: 'initialize-release'!

        initialize: srodek and: bok
        	"tworz kwadrat o podanym boku"
        
        	super initialize: 6 name: 'Szesciokat'.

        	wierzcholki at: 2 put: (-1/2*bok)@((3 sqrt) / 2 * bok).
        	wierzcholki at: 3 put: 0@((3 sqrt)*bok).
        	wierzcholki at: 4 put: bok@((3 sqrt)*bok).
        	wierzcholki at: 5 put: ((3/2)*bok)@(((3 sqrt)/2)*bok).
        	wierzcholki at: 6 put: bok@0.
        
        	
        	"przesuniecie do srodka ukladu wspolrzednych"
        	1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x - (1/2 * bok))@((wierzcholki at: index) y - ((3 sqrt) / 2 * bok)).
            ].
        	
        	"przesuniecie o srodek"
            1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x + srodek x)@((wierzcholki at: index) y + srodek y).
            ].
        	Srodek:=srodek. 
        	Bok:=bok
        ! 
        initialize: bok
            self initialize: (bok/2)@((3 sqrt) / 2 * bok) and: bok
        !
    !

    !Szesciokat methodsFor: 'arithmetic'!
        + figura
        	"dodaj 2 figury w sensie pola"
        	| p |
        	p:= self pole + figura pole.
        	Bok:= ((2*p)/(3*(3 sqrt))) sqrt.
        	
        	super + figura.
        	^(Szesciokat new) initialize: Srodek and: Bok
        !
    !
    
    !Szesciokat methodsFor: 'actions'!
        pole
        	"licz pole szeciokata"
        	^(( (3 * (3 sqrt)) / 2 )*(Bok squared))
        !
        wysrodkuj
           "petla z wierzcholkami"
            super wysrodkuj.
            self initialize: 0@0 and: Bok
        !
        drukuj
            super drukuj.
            
        !
        
    !    
        
Transcript show: '*******************Kwadrat*******************'; cr; cr.

"tworzenie dwóch kwadratów"
k1 := (Kwadrat new) initialize: 3.
k1 drukuj.
k2 := (Kwadrat new) initialize: 4.
k2 drukuj.

"dodawanie pola"
k3 := k1 + k2.
k3 drukuj.

"wyśrodkowanie"
k3 wysrodkuj.
k3 drukuj.


Transcript show: '*******************Szesciokat*******************'; cr; cr.

"tworzenie sześciokąta"
sz := (Szesciokat new) initialize: 2.
sz drukuj.

"wyśrodkowanie"
sz wysrodkuj.
sz drukuj.

"dodawanie pola"
sz2 := sz + k1.
sz2 drukuj.
