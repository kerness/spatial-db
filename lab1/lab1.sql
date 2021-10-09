create database firma;
create schema ksiegowosc;

-- ##################################

create table ksiegowosc.pracownicy(
	id_pracownika int primary key,
	imie varchar(25) not null,
	nazwisko varchar(25) not null,
	adres varchar(50),
	telefon varchar(12)
);
create table ksiegowosc.godziny(
	id_godziny int primary key, 
	data date not null, 
	liczba_godzin int not null, 
	id_pracownika int not null
);
create table ksiegowosc.pensja(
	id_pensji int primary key, 
	stanowisko varchar(50) not null, 
	kwota float not null
);
create table ksiegowosc.premia(
	id_premii int primary key, 
	rodzaj varchar(50), 
	kwota float 
);
create table ksiegowosc.wynagrodzenie(
	id_wynagrodzenia int primary key, 
	data date not null, 
	id_pracownika int not null, 
	id_godziny int not null, 
	id_pensji int not null, 
	id_premii int not null
);

-- ##################################

COMMENT ON TABLE ksiegowosc.pracownicy IS 'Podstawowe dane personalne pracownik?w';
COMMENT ON TABLE ksiegowosc.godziny IS 'Informacje o liczbie godzin przepracowanych przez poszczeg?lnych pracpwnik?w';
COMMENT ON TABLE ksiegowosc.pensja IS 'Wysoko?? pensji odpowiadaj?ca danemu stanowiskowi';
COMMENT ON TABLE ksiegowosc.premia IS 'Informacje na temat premii przyznanych pracownikom';
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Informacje dotycz?ce wszytskich wyp?aconych wynagrodze?';

-- ##################################

insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (1, 'Gill', 'Patmore', '7400 Hauk Drive', '889-957-4687');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (2, 'Joelle', 'Eaglen', '66109 Larry Place', '425-572-3733');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (3, 'Beau', 'D''Aubney', '41737 Barby Pass', '460-334-4178');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (4, 'Randi', 'Lempke', '1 Westend Street', '514-387-6680');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (5, 'Gino', 'Klisch', '47692 Melby Circle', '179-292-5896');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (6, 'Nollie', 'Morrieson', '82 Daystar Point', '880-300-7136');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (7, 'Ofilia', 'Delue', '78103 Boyd Avenue', '705-622-0473');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (8, 'Urson', 'Turfitt', '7705 Steensland Junction', '763-827-9258');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (9, 'Orelle', 'Tackley', '68 Hintze Place', '425-551-5951');
insert into ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) values (10, 'Rhona', 'Hartless', '83 Caliangt Road', '401-691-9527');

insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (1, '11/18/2020', 182, 1);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (2, '8/17/2021', 172, 2);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (3, '3/6/2021', 128, 3);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (4, '6/10/2021', 173, 4);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (5, '2/16/2021', 14, 5);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (6, '7/25/2021', 119, 6);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (7, '11/8/2020', 199, 7);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (8, '3/27/2021', 137, 8);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (9, '10/3/2021', 177, 9);
insert into ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) values (10, '5/10/2021', 14, 10);

insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (1, 'Software Consultant', 5072);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (2, 'Operator', 9776);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (3, 'Financial Analyst', 7463);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (4, 'Operator', 14667);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (5, 'Product Engineer', 7227);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (6, 'Software Consultant', 6593);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (7, 'GIS Technical Architect', 12349);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (8, 'Staff Scientist', 11568);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (9, 'GIS Technical Architect', 11678);
insert into ksiegowosc.pensja (id_pensji, stanowisko, kwota) values (10, 'Software Consultant', 8583);

insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (1, 'purus aliquet', 1115);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (2, 'duis consequat', 261);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (3, null, null);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (4, 'mauris ullamcorper', 601);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (5, 'orci vehicula', 617);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (6, null, null);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (7, 'platea dictumst', 1226);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (8, 'dolor sit', 985);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (9, null, null);
insert into ksiegowosc.premia (id_premii, rodzaj, kwota) values (10, 'massa tempor', 1153);

insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (1, '12/14/2020', 1, 1, 1, 1);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (2, '6/15/2021', 2, 2, 2, 2);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (3, '3/2/2021', 3, 3, 3, 3);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (4, '2/1/2021', 4, 4, 4, 4);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (5, '1/18/2021', 5, 5, 5, 5);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (6, '2/6/2021', 6, 6, 6, 6);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (7, '11/9/2020', 7, 7, 7, 7);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (8, '5/5/2021', 8, 8, 8, 8);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (9, '1/23/2021', 9, 9, 9, 9);
insert into ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) values (10, '11/4/2020', 10, 10, 10, 10);

-- ##################################
-- a
select id_pracownika, nazwisko from ksiegowosc.pracownicy;

-- b
select id_pracownika from ksiegowosc.wynagrodzenie w 
join ksiegowosc.pensja p on p.id_pensji = w.id_pensji
where kwota > 1000;

-- c
select id_pracownika from ksiegowosc.wynagrodzenie w 
join ksiegowosc.premia p on p.id_premii = w.id_premii
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji
where p.kwota is null and p2.kwota > 10000;

-- d
select imie, nazwisko from ksiegowosc.pracownicy p 
where p.imie like 'J%';

-- e
select imie, nazwisko from ksiegowosc.pracownicy p 
where p.nazwisko like '%n%' and p.imie like '%e';

-- f
select imie, nazwisko, abs(liczba_godzin-160) as nadgodziny
from ksiegowosc.pracownicy p 
join ksiegowosc.godziny g on p.id_pracownika = g.id_pracownika
where g.liczba_godzin > 160;

-- h
select imie, nazwisko from ksiegowosc.pracownicy p 
join ksiegowosc.wynagrodzenie w on w.id_pracownika = p.id_pracownika 
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji 
where kwota > 7000 and kwota < 10000;

--
select imie, nazwisko, abs(liczba_godzin-160) as nadgodziny
from ksiegowosc.pracownicy p 
join ksiegowosc.godziny g on p.id_pracownika = g.id_pracownika
join ksiegowosc.wynagrodzenie w on w.id_pracownika = g.id_pracownika
join ksiegowosc.premia p2 on p2.id_premii = w.id_premii
where g.liczba_godzin > 160 and p2.kwota is null;

-- j
select imie, nazwisko, kwota from ksiegowosc.pracownicy p 
join ksiegowosc.wynagrodzenie w on w.id_pracownika = p.id_pracownika
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji
order by kwota desc;

-- k
select imie, nazwisko, p2.kwota as pensja, p3.kwota as premia from ksiegowosc.pracownicy p
join ksiegowosc.wynagrodzenie w on w.id_pracownika = p.id_pracownika
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji
join ksiegowosc.premia p3 on p3.id_premii = w.id_premii
order by p2.kwota, p3.kwota desc;

-- l
select stanowisko, count(*) from ksiegowosc.pracownicy p 
join ksiegowosc.wynagrodzenie w on w.id_pracownika = p.id_pracownika
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji
group by (p2.stanowisko);

-- m
select avg(kwota), min(kwota), max(kwota) from ksiegowosc.pensja
where stanowisko = 'Operator';

-- n
select sum(p.kwota + p2.kwota) as sum from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on p.id_pensji = w.id_pensji
join ksiegowosc.premia p2 on p2.id_premii = w.id_premii;

-- o 
select sum((p.kwota + coalesce(p2.kwota, 0))) as sum, p.stanowisko from ksiegowosc.wynagrodzenie w
join ksiegowosc.pensja p on p.id_pensji = w.id_pensji
join ksiegowosc.premia p2 on p2.id_premii = w.id_premii
group by (p.stanowisko);

-- p
select count(p.id_premii), stanowisko from ksiegowosc.premia p
join ksiegowosc.wynagrodzenie w on w.id_premii = p.id_premii
join ksiegowosc.pensja p2 on p2.id_pensji = w.id_pensji
where p.kwota is not null
group by p2.stanowisko;

-- r
delete from ksiegowosc.pracownicy p 
using ksiegowosc.wynagrodzenie w, ksiegowosc.pensja p2
where p.id_pracownika = w.id_pracownika and p2.id_pensji = w.id_pensji
and p2.kwota < 9000;

select * from ksiegowosc.pracownicy;



