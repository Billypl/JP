"Student nr1: Michał Pawiłojć, 193159"
"Student nr2: Hanna Banasiak, 193078"

"https://www.jdoodle.com/execute-smalltalk-online/"

Object subclass: #Wielokat
	instanceVariableNames: 'wierzcholki nazwa '
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
                Transcript show: 'Wierzcholek ', index printString, ': ', wierzcholek printString; cr.
                
            ].
            Transcript show: 'Pole = ', self pole printString; cr.
        !   
    !




Wielokat subclass: #Kwadrat
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JezykiProgramowania'!

    !Kwadrat methodsFor: 'initialize-release'!

        initialize: bok
        	"tworz kwadrat o podanym boku"
        
        	super initialize: 4 name: 'Kwadrat'.
        	wierzcholki at: 2 put: bok@0.
        	wierzcholki at: 3 put: bok@bok.
        	wierzcholki at: 4 put: 0@bok.
        ! 
    !

    !Kwadrat methodsFor: 'arithmetic'!
        + figura
        	"dodaj 2 figury w sensie pola"
        	| p |
        	p:=self pole + figura pole.
        	^(Kwadrat new) initialize: p sqrt
        !
    !
    
    !Kwadrat methodsFor: 'actions'!
        pole
        	"licz pole kwadratu"
        	^(wierzcholki at: 2) x squared
        !
    !    
        
Wielokat subclass: #Szesciakat
	instanceVariableNames: 'Bok Srodek'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JezykiProgramowania'!

    !Szesciakat methodsFor: 'initialize-release'!

        initialize: srodek and: bok
        	"tworz kwadrat o podanym boku"
        
        	super initialize: 6 name: 'Szesciakat'.

        	wierzcholki at: 2 put: (-1/2*bok)@((3 sqrt) / 2 * bok).
        	wierzcholki at: 3 put: 0@((3 sqrt)*bok).
        	wierzcholki at: 4 put: bok@((3 sqrt)*bok).
        	wierzcholki at: 5 put: ((3/2)*bok)@(((3 sqrt)/2)*bok).
        	wierzcholki at: 6 put: bok@0.
        
        	Srodek:=srodek. "(bok/2)@(((3 sqrt)*bok)/2)"
        	
        	"przesuniecie do srodka ukladu wpolrzednych"
        	1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x - (1/2 * bok))@((wierzcholki at: index) y + ((3 sqrt) / 2 * bok)).
            ].
        	
        	"przesuniecie o srodek"
            1 to: wierzcholki size do: 
            [:index | 
                wierzcholki at: index put: ((wierzcholki at: index) x + Srodek x)@((wierzcholki at: index) y + Srodek y).
            ].
        	Bok:=bok
        ! 
    !

    !Szesciakat methodsFor: 'arithmetic'!
        + figura
        	"dodaj 2 figury w sensie pola"
        	| p |
        	p:=self pole + figura pole.
        	Bok:= ((2*p)/(3*(3 sqrt))) sqrt.
        	
        	^(Szesciakat new) initialize: Srodek and: Bok
        !
    !
    
    !Szesciakat methodsFor: 'actions'!
        pole
        	"licz pole szeciakata"
        	^(( (3 * (3 sqrt)) / 2 )*(Bok squared))
        !
        centruj
           "petla z wierzcholkami"
            self initialize: 0@0 and: Bok
        !
        drukuj
            super drukuj.
            Transcript show: 'Srodek: ', Srodek printString; cr.
        !
        
    !    
        
k := (Kwadrat new) initialize:2.

sz := (Szesciakat new) initialize: 1@-1.7320508075688772 and: 2. "szesciakat z wierzcholkiem jeden w 0@0"
Transcript show: '////////////////////Centrowanie/////////////////////'; cr.
sz drukuj.
sz centruj.
sz drukuj.

Transcript show: '////////////////////Dodawanie/////////////////////'; cr.
sz2 := sz + k.
sz2 drukuj.
