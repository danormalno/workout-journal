import Foundation

/// Розділ інструкції: іконка + заголовок + текст (9 мов через LocStr).
struct InstructionSection: Identifiable {
    let id = UUID()
    let icon: String
    let title: LocStr
    let body: LocStr
}

/// Інструкція з користування додатком на всіх підтримуваних мовах.
enum AppInstructions {

    /// Заголовок екрана інструкції.
    static func title(for lang: AppLanguage?) -> String {
        switch lang {
        case .en: return "How to use the app"
        case .ru: return "Как пользоваться приложением"
        case .es: return "Cómo usar la aplicación"
        case .de: return "App-Anleitung"
        case .fr: return "Comment utiliser l'application"
        case .pt: return "Como usar o aplicativo"
        case .pl: return "Jak korzystać z aplikacji"
        case .it: return "Come usare l'app"
        default: return "Як користуватися додатком"
        }
    }

    /// Підзаголовок під назвою застосунку.
    static func tagline(for lang: AppLanguage?) -> String {
        LocStr(
            "Твій щоденник тренувань",
            "Your training journal",
            "Твой дневник тренировок",
            "Tu diario de entrenamiento",
            "Dein Trainingstagebuch",
            "Ton journal d'entraînement",
            "Seu diário de treino",
            "Twój dziennik treningowy",
            "Il tuo diario di allenamento"
        ).s(lang)
    }

    /// Текстова версія (міст для будь-яких старих викликів).
    static func fullText(for lang: AppLanguage?) -> String {
        sections.map { "\($0.title.s(lang))\n\($0.body.s(lang))" }
            .joined(separator: "\n\n———\n\n")
    }

    // MARK: - Розділи

    static let sections: [InstructionSection] = [
        InstructionSection(
            icon: "hand.wave.fill",
            title: LocStr("Ласкаво просимо","Welcome","Добро пожаловать","Bienvenido","Willkommen","Bienvenue","Bem-vindo","Witaj","Benvenuto"),
            body: LocStr(
                "WillWin — твій щоденник тренувань: плануй тижні, фіксуй підходи й вагу, стеж за прогресом і бий власні рекорди.",
                "WillWin is your training journal: plan weeks, log sets and weights, track progress and beat your own records.",
                "WillWin — твой дневник тренировок: планируй недели, фиксируй подходы и вес, следи за прогрессом и бей свои рекорды.",
                "WillWin es tu diario de entrenamiento: planifica semanas, registra series y pesos, sigue tu progreso y supera tus récords.",
                "WillWin ist dein Trainingstagebuch: plane Wochen, protokolliere Sätze und Gewichte, verfolge Fortschritte und brich deine Rekorde.",
                "WillWin est ton journal d'entraînement : planifie des semaines, enregistre séries et poids, suis tes progrès et bats tes records.",
                "WillWin é o seu diário de treino: planeje semanas, registre séries e pesos, acompanhe o progresso e bata seus recordes.",
                "WillWin to twój dziennik treningowy: planuj tygodnie, zapisuj serie i ciężary, śledź postępy i bij własne rekordy.",
                "WillWin è il tuo diario di allenamento: pianifica settimane, registra serie e pesi, monitora i progressi e batti i tuoi record."
            )
        ),
        InstructionSection(
            icon: "calendar",
            title: LocStr("Тижні і тренування","Weeks & workouts","Недели и тренировки","Semanas y entrenamientos","Wochen & Trainings","Semaines & entraînements","Semanas e treinos","Tygodnie i treningi","Settimane e allenamenti"),
            body: LocStr(
                "На вкладці «Тижні» додавай тиждень кнопкою «+», заходь усередину й створюй тренування (до 14). У кожному — вправи, кардіо в кінці та нотатки.",
                "On the «Weeks» tab add a week with «+», open it and create workouts (up to 14). Each holds exercises, cardio at the end, and notes.",
                "На вкладке «Недели» добавляй неделю кнопкой «+», заходи внутрь и создавай тренировки (до 14). В каждой — упражнения, кардио в конце и заметки.",
                "En la pestaña «Semanas» añade una semana con «+», ábrela y crea entrenamientos (hasta 14). Cada uno tiene ejercicios, cardio al final y notas.",
                "Im Reiter «Wochen» füge mit «+» eine Woche hinzu, öffne sie und erstelle Trainings (bis zu 14). Jedes enthält Übungen, Cardio am Ende und Notizen.",
                "Dans l'onglet «Semaines» ajoute une semaine avec «+», ouvre-la et crée des entraînements (jusqu'à 14). Chacun contient exercices, cardio à la fin et notes.",
                "Na aba «Semanas» adicione uma semana com «+», abra-a e crie treinos (até 14). Cada um tem exercícios, cardio no fim e notas.",
                "W zakładce «Tygodnie» dodaj tydzień przyciskiem «+», wejdź i twórz treningi (do 14). Każdy zawiera ćwiczenia, cardio na końcu i notatki.",
                "Nella scheda «Settimane» aggiungi una settimana con «+», aprila e crea allenamenti (fino a 14). Ognuno ha esercizi, cardio alla fine e note."
            )
        ),
        InstructionSection(
            icon: "books.vertical.fill",
            title: LocStr("Готові програми","Ready-made programs","Готовые программы","Programas listos","Fertige Programme","Programmes prêts","Programas prontos","Gotowe programy","Programmi pronti"),
            body: LocStr(
                "У шаблонах є каталог готових програм для чоловіків і жінок (новачкам, на силу, масу, сушку, сідниці тощо). Обери програму — вона додасть тренування з уже проставленими повторами, лишиться вписати вагу.",
                "Templates include a catalog of ready programs for men and women (beginner, strength, size, cutting, glutes, etc.). Pick one — it adds workouts with reps pre-filled; just enter the weights.",
                "В шаблонах есть каталог готовых программ для мужчин и женщин (новичкам, на силу, массу, сушку, ягодицы и т.д.). Выбери программу — она добавит тренировки с уже проставленными повторами, останется вписать вес.",
                "Las plantillas incluyen un catálogo de programas listos para hombres y mujeres (principiante, fuerza, volumen, definición, glúteos, etc.). Elige uno — añade entrenamientos con repeticiones ya puestas; solo pon los pesos.",
                "Vorlagen enthalten einen Katalog fertiger Programme für Männer und Frauen (Anfänger, Kraft, Masse, Definition, Po usw.). Wähle eins — es fügt Trainings mit vorausgefüllten Wiederholungen hinzu; trage nur die Gewichte ein.",
                "Les modèles incluent un catalogue de programmes prêts pour hommes et femmes (débutant, force, masse, sèche, fessiers, etc.). Choisis-en un — il ajoute des entraînements avec répétitions pré-remplies ; entre juste les poids.",
                "Os modelos incluem um catálogo de programas prontos para homens e mulheres (iniciante, força, massa, definição, glúteos, etc.). Escolha um — adiciona treinos com repetições já preenchidas; basta inserir os pesos.",
                "Szablony zawierają katalog gotowych programów dla mężczyzn i kobiet (początkujący, siła, masa, redukcja, pośladki itd.). Wybierz jeden — doda treningi z już wpisanymi powtórzeniami; podaj tylko ciężary.",
                "I modelli includono un catalogo di programmi pronti per uomini e donne (principianti, forza, massa, definizione, glutei, ecc.). Scegline uno — aggiunge allenamenti con ripetizioni già inserite; basta mettere i pesi."
            )
        ),
        InstructionSection(
            icon: "figure.strengthtraining.traditional",
            title: LocStr("Підходи і вага","Sets & weight","Подходы и вес","Series y peso","Sätze & Gewicht","Séries & poids","Séries e peso","Serie i ciężar","Serie e peso"),
            body: LocStr(
                "Додай вправу і тисни «+», щоб додати підхід. Новий підхід підставляє вагу попереднього. Під назвою вправи є капсула «↳ минулого разу» — тап по ній заповнює вагу й повтори з минулого тренування. Тоннаж рахується автоматично.",
                "Add an exercise and tap «+» to add a set. A new set copies the previous one's weight. Under the exercise name there's a «↳ last time» chip — tap it to fill the weight and reps from your last session. Tonnage is auto-counted.",
                "Добавь упражнение и жми «+», чтобы добавить подход. Новый подход подставляет вес предыдущего. Под названием упражнения есть капсула «↳ прошлый раз» — тап по ней заполняет вес и повторы из прошлой тренировки. Тоннаж считается автоматически.",
                "Añade un ejercicio y toca «+» para una serie. La nueva serie copia el peso de la anterior. Bajo el nombre hay una etiqueta «↳ la última vez» — tócala para rellenar peso y repeticiones de tu sesión anterior. El tonelaje se cuenta solo.",
                "Füge eine Übung hinzu und tippe «+» für einen Satz. Ein neuer Satz übernimmt das Gewicht des vorherigen. Unter dem Namen gibt es einen Chip «↳ letztes Mal» — tippe ihn, um Gewicht und Wiederholungen der letzten Einheit zu übernehmen. Die Tonnage zählt automatisch.",
                "Ajoute un exercice et tape «+» pour une série. Une nouvelle série reprend le poids de la précédente. Sous le nom, une pastille «↳ la dernière fois» — tape dessus pour remplir poids et répétitions de ta dernière séance. Le tonnage se calcule seul.",
                "Adicione um exercício e toque «+» para uma série. Uma nova série copia o peso da anterior. Sob o nome há um chip «↳ da última vez» — toque para preencher peso e repetições da sessão anterior. A tonelagem é contada sozinha.",
                "Dodaj ćwiczenie i stuknij «+», aby dodać serię. Nowa seria kopiuje ciężar poprzedniej. Pod nazwą jest etykieta «↳ poprzednio» — stuknij, aby wpisać ciężar i powtórzenia z poprzedniego treningu. Tonaż liczy się automatycznie.",
                "Aggiungi un esercizio e tocca «+» per una serie. Una nuova serie copia il peso della precedente. Sotto il nome c'è un chip «↳ l'ultima volta» — toccalo per inserire peso e ripetizioni dell'ultima sessione. Il tonnellaggio si conta da solo."
            )
        ),
        InstructionSection(
            icon: "trophy.fill",
            title: LocStr("Перевершити минуле","Beat last workout","Превзойти прошлое","Superar el anterior","Letztes übertreffen","Battre la dernière","Superar o anterior","Pobij poprzedni","Battere il precedente"),
            body: LocStr(
                "Угорі тренування зʼявляється плашка: скільки тоннажу лишилось, щоб перевершити минуле однотипне тренування. Коли переб'єш — побачиш підтвердження з трофеєм.",
                "At the top of a workout a banner shows how much tonnage you still need to beat your last similar workout. When you pass it, you get a trophy confirmation.",
                "Вверху тренировки появляется плашка: сколько тоннажа осталось, чтобы превзойти прошлую однотипную тренировку. Когда побьёшь — увидишь подтверждение с трофеем.",
                "Arriba del entrenamiento un aviso muestra cuánto tonelaje te falta para superar tu último entrenamiento similar. Al superarlo, ves una confirmación con trofeo.",
                "Oben im Training zeigt ein Banner, wie viel Tonnage dir fehlt, um dein letztes gleichartiges Training zu übertreffen. Schaffst du es, gibt's eine Trophäen-Bestätigung.",
                "En haut d'une séance, une bannière indique combien de tonnage il te manque pour battre ta dernière séance similaire. Quand tu y arrives, tu obtiens une confirmation avec trophée.",
                "No topo do treino, um aviso mostra quanto tonelagem falta para superar seu último treino semelhante. Ao superar, vê uma confirmação com troféu.",
                "Na górze treningu baner pokazuje, ile tonażu brakuje, by pobić poprzedni podobny trening. Gdy go pobijesz — zobaczysz potwierdzenie z trofeum.",
                "In alto nell'allenamento un banner mostra quanto tonnellaggio ti manca per battere l'ultimo allenamento simile. Quando lo superi, vedi una conferma con trofeo."
            )
        ),
        InstructionSection(
            icon: "timer",
            title: LocStr("Таймер відпочинку","Rest timer","Таймер отдыха","Temporizador de descanso","Pausentimer","Minuteur de repos","Cronômetro de descanso","Timer odpoczynku","Timer di riposo"),
            body: LocStr(
                "Між підходами вмикається таймер. Працює навіть із заблокованим екраном — прийде сповіщення зі звуком/вібрацією, а відлік вібрує в останні секунди. Час і звук — у Налаштуваннях.",
                "A timer starts between sets. It works even with the screen locked — you get a sound/vibration notification, and the countdown vibrates in the final seconds. Time and sound — in Settings.",
                "Между подходами включается таймер. Работает даже с заблокированным экраном — придёт уведомление со звуком/вибрацией, а отсчёт вибрирует в последние секунды. Время и звук — в Настройках.",
                "Entre series arranca un temporizador. Funciona con la pantalla bloqueada — recibes una notificación con sonido/vibración y la cuenta vibra en los últimos segundos. Tiempo y sonido — en Configuración.",
                "Zwischen Sätzen startet ein Timer. Er läuft auch bei gesperrtem Bildschirm — du bekommst eine Ton/Vibration-Benachrichtigung, und der Countdown vibriert in den letzten Sekunden. Zeit und Ton — in den Einstellungen.",
                "Un minuteur démarre entre les séries. Il fonctionne écran verrouillé — tu reçois une notification son/vibration, et le décompte vibre dans les dernières secondes. Durée et son — dans Paramètres.",
                "Um cronômetro inicia entre séries. Funciona com a tela bloqueada — você recebe notificação com som/vibração e a contagem vibra nos últimos segundos. Tempo e som — em Configurações.",
                "Między seriami startuje timer. Działa też przy zablokowanym ekranie — dostaniesz powiadomienie z dźwiękiem/wibracją, a odliczanie wibruje w ostatnich sekundach. Czas i dźwięk — w Ustawieniach.",
                "Tra le serie parte un timer. Funziona anche con schermo bloccato — ricevi una notifica con suono/vibrazione e il conto vibra negli ultimi secondi. Tempo e suono — in Impostazioni."
            )
        ),
        InstructionSection(
            icon: "arrow.triangle.2.circlepath",
            title: LocStr("Цикли тренувань","Training cycles","Циклы тренировок","Ciclos de entrenamiento","Trainingszyklen","Cycles d'entraînement","Ciclos de treino","Cykle treningowe","Cicli di allenamento"),
            body: LocStr(
                "Цикл — група послідовних тренувань. Додаток порівнює тоннаж між циклами й показує прогрес у відсотках. Розмір циклу — у Налаштуваннях (кроковим вибором ±).",
                "A cycle is a group of consecutive workouts. The app compares tonnage between cycles and shows progress in percent. Cycle size — in Settings (stepper ±).",
                "Цикл — группа последовательных тренировок. Приложение сравнивает тоннаж между циклами и показывает прогресс в процентах. Размер цикла — в Настройках (шаговым выбором ±).",
                "Un ciclo es un grupo de entrenamientos consecutivos. La app compara el tonelaje entre ciclos y muestra el progreso en porcentaje. Tamaño de ciclo — en Configuración (con ±).",
                "Ein Zyklus ist eine Gruppe aufeinanderfolgender Trainings. Die App vergleicht die Tonnage zwischen Zyklen und zeigt den Fortschritt in Prozent. Zyklusgröße — in den Einstellungen (mit ±).",
                "Un cycle est un groupe d'entraînements consécutifs. L'app compare le tonnage entre cycles et montre le progrès en pourcentage. Taille du cycle — dans Paramètres (avec ±).",
                "Um ciclo é um grupo de treinos consecutivos. O app compara a tonelagem entre ciclos e mostra o progresso em porcentagem. Tamanho do ciclo — em Configurações (com ±).",
                "Cykl to grupa kolejnych treningów. Aplikacja porównuje tonaż między cyklami i pokazuje postęp w procentach. Rozmiar cyklu — w Ustawieniach (przyciskami ±).",
                "Un ciclo è un gruppo di allenamenti consecutivi. L'app confronta il tonnellaggio tra i cicli e mostra il progresso in percentuale. Dimensione del ciclo — in Impostazioni (con ±)."
            )
        ),
        InstructionSection(
            icon: "chart.xyaxis.line",
            title: LocStr("Прогрес","Progress","Прогресс","Progreso","Fortschritt","Progrès","Progresso","Postęp","Progresso"),
            body: LocStr(
                "Вкладка «Прогрес» малює графік робочої ваги по обраній вправі. Діапазон (8/16 тижнів або весь час) — у Налаштуваннях.",
                "The «Progress» tab draws a working-weight chart for the chosen exercise. Range (8/16 weeks or all time) — in Settings.",
                "Вкладка «Прогресс» рисует график рабочего веса по выбранному упражнению. Диапазон (8/16 недель или всё время) — в Настройках.",
                "La pestaña «Progreso» dibuja un gráfico del peso de trabajo del ejercicio elegido. Rango (8/16 semanas o todo) — en Configuración.",
                "Der Reiter «Fortschritt» zeichnet ein Arbeitsgewicht-Diagramm für die gewählte Übung. Bereich (8/16 Wochen oder gesamt) — in den Einstellungen.",
                "L'onglet «Progrès» trace un graphique du poids de travail pour l'exercice choisi. Plage (8/16 semaines ou tout) — dans Paramètres.",
                "A aba «Progresso» desenha um gráfico do peso de trabalho do exercício escolhido. Intervalo (8/16 semanas ou tudo) — em Configurações.",
                "Zakładka «Postęp» rysuje wykres ciężaru roboczego dla wybranego ćwiczenia. Zakres (8/16 tygodni lub całość) — w Ustawieniach.",
                "La scheda «Progresso» disegna un grafico del peso di lavoro per l'esercizio scelto. Intervallo (8/16 settimane o tutto) — in Impostazioni."
            )
        ),
        InstructionSection(
            icon: "flame.fill",
            title: LocStr("Серії, ачивки, теплова мапа","Streaks, achievements, heatmap","Серии, ачивки, тепловая карта","Rachas, logros, mapa de calor","Serien, Erfolge, Heatmap","Séries, succès, carte de chaleur","Sequências, conquistas, mapa de calor","Serie, osiągnięcia, mapa cieplna","Serie, obiettivi, mappa di calore"),
            body: LocStr(
                "На «Прогрес → Теплова мапа» видно календар тренувань, серію тижнів поспіль і досягнення. Кнопка «Підсумок тижня» робить картку з тоннажем, тренуваннями й новими PR — нею можна поділитися.",
                "Under «Progress → Heatmap» you'll see a training calendar, your week streak and achievements. The «Weekly summary» button makes a shareable card with tonnage, workouts and new PRs.",
                "В «Прогресс → Тепловая карта» видно календарь тренировок, серию недель подряд и достижения. Кнопка «Итоги недели» делает карточку с тоннажем, тренировками и новыми PR — ею можно поделиться.",
                "En «Progreso → Mapa de calor» ves un calendario de entrenamientos, tu racha de semanas y logros. El botón «Resumen semanal» crea una tarjeta para compartir con tonelaje, entrenamientos y nuevos récords.",
                "Unter «Fortschritt → Heatmap» siehst du einen Trainingskalender, deine Wochen-Serie und Erfolge. Der Button «Wochenbilanz» erstellt eine teilbare Karte mit Tonnage, Trainings und neuen PRs.",
                "Dans «Progrès → Carte de chaleur» tu vois un calendrier d'entraînement, ta série de semaines et tes succès. Le bouton «Bilan de la semaine» crée une carte partageable avec tonnage, séances et nouveaux records.",
                "Em «Progresso → Mapa de calor» você vê um calendário de treinos, sua sequência de semanas e conquistas. O botão «Resumo semanal» cria um cartão para compartilhar com tonelagem, treinos e novos recordes.",
                "W «Postęp → Mapa cieplna» zobaczysz kalendarz treningów, serię tygodni i osiągnięcia. Przycisk «Podsumowanie tygodnia» tworzy kartę do udostępnienia z tonażem, treningami i nowymi rekordami.",
                "In «Progresso → Mappa di calore» vedi un calendario degli allenamenti, la tua serie di settimane e gli obiettivi. Il pulsante «Riepilogo settimanale» crea una scheda condivisibile con tonnellaggio, allenamenti e nuovi record."
            )
        ),
        InstructionSection(
            icon: "scalemass.fill",
            title: LocStr("Моя вага","Body weight","Мой вес","Mi peso","Mein Gewicht","Mon poids","Meu peso","Moja waga","Il mio peso"),
            body: LocStr(
                "На вкладці «Моя вага» крути барабан (кілограми + соті, напр. 87,43) і тисни «Зберегти». Графік покаже динаміку ваги тіла.",
                "On the «Body weight» tab spin the wheel (kilograms + hundredths, e.g. 87.43) and tap «Save». The chart shows your bodyweight trend.",
                "На вкладке «Мой вес» крути барабан (килограммы + сотые, напр. 87,43) и жми «Сохранить». График покажет динамику веса тела.",
                "En la pestaña «Mi peso» gira la rueda (kilogramos + centésimas, ej. 87,43) y toca «Guardar». El gráfico muestra la tendencia de tu peso.",
                "Im Reiter «Mein Gewicht» drehe das Rad (Kilogramm + Hundertstel, z.B. 87,43) und tippe «Speichern». Das Diagramm zeigt deinen Gewichtsverlauf.",
                "Dans l'onglet «Mon poids» fais tourner la molette (kilos + centièmes, ex. 87,43) et tape «Enregistrer». Le graphique montre l'évolution de ton poids.",
                "Na aba «Meu peso» gire a roda (quilos + centésimos, ex. 87,43) e toque «Salvar». O gráfico mostra a tendência do seu peso.",
                "W zakładce «Moja waga» kręć bębnem (kilogramy + setne, np. 87,43) i stuknij «Zapisz». Wykres pokaże dynamikę wagi ciała.",
                "Nella scheda «Il mio peso» gira la rotella (chili + centesimi, es. 87,43) e tocca «Salva». Il grafico mostra l'andamento del tuo peso."
            )
        ),
        InstructionSection(
            icon: "slider.horizontal.3",
            title: LocStr("Оформлення та інструменти","Appearance & tools","Оформление и инструменты","Apariencia y herramientas","Design & Werkzeuge","Apparence et outils","Aparência e ferramentas","Wygląd i narzędzia","Aspetto e strumenti"),
            body: LocStr(
                "Усі функції безкоштовні. У Налаштуваннях змінюй акцентний колір і фон, експортуй дані у CSV. Калькулятори, рекорди, графіки, шаблони та фото прогресу доступні в «Додаткових інструментах».",
                "All features are free. In Settings, change the accent color and background or export data as CSV. Calculators, records, charts, templates and progress photos are in Extra Tools.",
                "Все функции бесплатны. В Настройках меняй акцентный цвет и фон, экспортируй данные в CSV. Калькуляторы, рекорды, графики, шаблоны и фото прогресса — в Дополнительных инструментах.",
                "Todas las funciones son gratis. En Configuración, cambia el color de acento y el fondo o exporta datos a CSV. Calculadoras, récords, gráficos, plantillas y fotos de progreso están en Herramientas extra.",
                "Alle Funktionen sind kostenlos. In den Einstellungen kannst du Akzentfarbe und Hintergrund ändern oder Daten als CSV exportieren. Rechner, Rekorde, Diagramme, Vorlagen und Fortschrittsfotos findest du unter Zusatz-Tools.",
                "Toutes les fonctions sont gratuites. Dans Réglages, change la couleur d'accent et le fond ou exporte les données en CSV. Calculateurs, records, graphiques, modèles et photos de progression sont dans Outils supplémentaires.",
                "Todos os recursos são gratuitos. Em Configurações, altere a cor de destaque e o fundo ou exporte dados em CSV. Calculadoras, recordes, gráficos, modelos e fotos de progresso ficam em Ferramentas extra.",
                "Wszystkie funkcje są bezpłatne. W Ustawieniach zmień kolor akcentu i tło lub wyeksportuj dane do CSV. Kalkulatory, rekordy, wykresy, szablony i zdjęcia postępów znajdziesz w Dodatkowych narzędziach.",
                "Tutte le funzioni sono gratuite. Nelle Impostazioni puoi cambiare il colore e lo sfondo o esportare i dati in CSV. Calcolatori, record, grafici, modelli e foto dei progressi sono negli Strumenti extra."
            )
        ),
        InstructionSection(
            icon: "externaldrive.fill",
            title: LocStr("Дані та бекап","Data & backup","Данные и бэкап","Datos y copia","Daten & Backup","Données & sauvegarde","Dados e backup","Dane i kopia","Dati e backup"),
            body: LocStr(
                "У Налаштуваннях експортуй дані у JSON для резервної копії чи перенесення на інший iPhone, і так само імпортуй назад. Кастомні вправи зберігаються назавжди, навіть якщо видалити тренування з ними.",
                "In Settings export your data to JSON for backup or moving to another iPhone, and import it back. Custom exercises are kept forever, even if you delete workouts that used them.",
                "В Настройках экспортируй данные в JSON для резервной копии или переноса на другой iPhone, и так же импортируй назад. Кастомные упражнения сохраняются навсегда, даже если удалить тренировки с ними.",
                "En Configuración exporta tus datos a JSON para copia o pasar a otro iPhone, e impórtalos de vuelta. Los ejercicios personalizados se guardan para siempre, aunque borres entrenamientos que los usaban.",
                "Exportiere in den Einstellungen deine Daten als JSON für Backup oder Wechsel zu einem anderen iPhone und importiere sie wieder. Eigene Übungen bleiben für immer erhalten, auch wenn du Trainings damit löschst.",
                "Dans Paramètres, exporte tes données en JSON pour sauvegarde ou transfert vers un autre iPhone, et réimporte-les. Les exercices personnalisés sont conservés à jamais, même si tu supprimes les séances qui les utilisaient.",
                "Em Configurações exporte seus dados para JSON para backup ou mudar de iPhone, e importe de volta. Exercícios personalizados ficam guardados para sempre, mesmo apagando treinos que os usavam.",
                "W Ustawieniach eksportuj dane do JSON jako kopię lub do przeniesienia na inny iPhone i importuj z powrotem. Niestandardowe ćwiczenia są zapisane na zawsze, nawet po usunięciu treningów z nimi.",
                "In Impostazioni esporta i dati in JSON per backup o per passare a un altro iPhone, e reimportali. Gli esercizi personalizzati restano per sempre, anche se elimini gli allenamenti che li usavano."
            )
        ),
        InstructionSection(
            icon: "lightbulb.fill",
            title: LocStr("Поради","Tips","Советы","Consejos","Tipps","Conseils","Dicas","Wskazówki","Consigli"),
            body: LocStr(
                "Тренуйся регулярно — серія тижнів і ачивки мотивують. Час від часу роби експорт даних. Ділись тижневою карткою — це гарний спосіб тримати темп.",
                "Train regularly — the week streak and achievements keep you motivated. Export your data now and then. Share the weekly card — a nice way to stay consistent.",
                "Тренируйся регулярно — серия недель и ачивки мотивируют. Время от времени делай экспорт данных. Делись недельной карточкой — отличный способ держать темп.",
                "Entrena con regularidad — la racha y los logros motivan. Exporta tus datos de vez en cuando. Comparte la tarjeta semanal — una buena forma de mantener el ritmo.",
                "Trainiere regelmäßig — die Wochen-Serie und Erfolge motivieren. Exportiere ab und zu deine Daten. Teile die Wochenkarte — eine schöne Art, dranzubleiben.",
                "Entraîne-toi régulièrement — la série et les succès motivent. Exporte tes données de temps en temps. Partage la carte hebdo — un bon moyen de garder le rythme.",
                "Treine com regularidade — a sequência e as conquistas motivam. Exporte seus dados de vez em quando. Compartilhe o cartão semanal — um bom jeito de manter o ritmo.",
                "Trenuj regularnie — seria tygodni i osiągnięcia motywują. Od czasu do czasu eksportuj dane. Udostępniaj kartę tygodnia — dobry sposób na utrzymanie tempa.",
                "Allenati con regolarità — la serie e gli obiettivi motivano. Esporta i dati ogni tanto. Condividi la scheda settimanale — un buon modo per restare costante."
            )
        ),
    ]
}
