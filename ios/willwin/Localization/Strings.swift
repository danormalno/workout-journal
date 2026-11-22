import Foundation
import SwiftUI

struct Strings {
    let weeks: String
    let week: String
    let workouts: String
    let workout: String
    let progress: String
    let bodyWeight: String
    let settings: String
    
    let addWeek: String
    let addWorkout: String
    let addExercise: String
    let addBlock: String
    let addCardio: String
    let duplicate: String
    let delete: String
    let cancel: String
    let save: String
    let done: String
    let edit: String
    let rename: String
    let renameNumber: String
    let renameName: String
    
    let weekNumber: String
    let workoutNumber: String
    let nameOptional: String
    let tonnage: String
    let kg: String
    let lb: String
    let reps: String
    let weight: String
    let sets: String
    let minutes: String
    let min: String
    let sec: String
    let notesPlaceholder: String
    let notesTitle: String
    let blockName: String
    let blockNamePlaceholder: String
    
    let noWeeksYet: String
    let noWorkoutsYet: String
    let noExercisesYet: String
    let maxWorkoutsReached: String
    let maxExercisesReached: String
    let maxSetsReached: String
    let maxCardioReached: String
    
    let chooseLanguage: String
    let chooseLanguageSubtitle: String
    
    let confirmDelete: String
    let deleteWeekMessage: String
    let deleteWorkoutMessage: String
    let deleteExerciseMessage: String
    
    let exercises: String
    let date: String
    
    let exerciseLibrary: String
    let cardioLibrary: String
    let searchExercises: String
    let searchCardio: String
    let alphabetical: String
    let byMuscleGroup: String
    let allGroups: String
    let myExercises: String
    let addCustomExercise: String
    let addCustomCardio: String
    let useThisExercise: String
    let exerciseName: String
    let cardioName: String
    let muscleGroup: String
    let nothingFound: String
    let createAsCustom: String
    
    let muscleChest: String
    let muscleBack: String
    let muscleShoulders: String
    let muscleBiceps: String
    let muscleTriceps: String
    let muscleLegs: String
    let muscleAbs: String
    let muscleCardio: String
    let muscleOther: String
    
    let cardioBefore: String
    let cardioAfter: String
    let cardioTime: String
    
    let cycleSize: String
    let cycleSizeGlobal: String
    let cycleSizeOverride: String
    let cycleSizeOverrideHelp: String
    let cycle: String
    let currentCycle: String
    let previousCycle: String
    let cycleComparison: String
    let totalTonnageChange: String
    let exercisesImproved: String
    let exercisesDeclined: String
    let exercisesNoChange: String
    let needMoreCyclesToCompare: String
    let needMoreCyclesHint: String
    let noCommonExercises: String
    let progressByExercise: String
    let progressByCycles: String
    let weightProgressed: String
    let repsProgressed: String
    let tonnageProgressed: String
    let noChange: String
    
    // Таймер
    let restTimer: String
    let restAfterSet: String
    let timerSound: String
    let soundBeep: String
    let soundBell: String
    let soundChime: String
    let soundDing: String
    let soundNone: String
    let preview: String
    let vibration: String
    let defaultRestTime: String
    let stopTimer: String
    let restCustom: String
    
    
    
    static let uk = Strings(
        weeks: "Тижні", week: "Тиждень", workouts: "Тренування", workout: "Тренування",
        progress: "Прогрес", bodyWeight: "Моя вага", settings: "Налаштування",
        addWeek: "Додати тиждень", addWorkout: "Додати тренування", addExercise: "Додати вправу",
        addBlock: "Додати розділ", addCardio: "Додати кардіо",
        duplicate: "Дублювати", delete: "Видалити", cancel: "Скасувати", save: "Зберегти",
        done: "Готово", edit: "Редагувати",
        rename: "Перейменувати", renameNumber: "Змінити номер", renameName: "Змінити назву",
        weekNumber: "Номер тижня", workoutNumber: "Номер тренування",
        nameOptional: "Назва (опційно)", tonnage: "Тоннаж", kg: "кг", lb: "фунт",
        reps: "повторів", weight: "Вага", sets: "Підходи", minutes: "хвилин", min: "хв", sec: "сек",
        notesPlaceholder: "Як пройшло тренування? Що покращити наступного разу?",
        notesTitle: "Коментар", blockName: "Назва розділу", blockNamePlaceholder: "Напр. Груди, Ноги",
        noWeeksYet: "Тут поки порожньо.\nДодай свій перший тиждень.",
        noWorkoutsYet: "У цьому тижні ще немає тренувань.",
        noExercisesYet: "У цьому тренуванні ще немає вправ.",
        maxWorkoutsReached: "Максимум 14 тренувань у тижні",
        maxExercisesReached: "Максимум 10 вправ у тренуванні",
        maxSetsReached: "Максимум 10 підходів у вправі",
        maxCardioReached: "Максимум 3 кардіо",
        chooseLanguage: "Оберіть мову", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Підтвердження",
        deleteWeekMessage: "Видалити цей тиждень разом з усіма тренуваннями?",
        deleteWorkoutMessage: "Видалити це тренування?",
        deleteExerciseMessage: "Видалити цю вправу?",
        exercises: "вправ", date: "Дата",
        exerciseLibrary: "База вправ", cardioLibrary: "База кардіо",
        searchExercises: "Пошук вправи…", searchCardio: "Пошук кардіо…",
        alphabetical: "За алфавітом", byMuscleGroup: "За групами", allGroups: "Усі",
        myExercises: "Мої вправи", addCustomExercise: "Додати власну вправу",
        addCustomCardio: "Додати власне кардіо",
        useThisExercise: "Обрати", exerciseName: "Назва вправи", cardioName: "Назва кардіо",
        muscleGroup: "М'язова група", nothingFound: "Нічого не знайдено",
        createAsCustom: "Створити як нову вправу",
        muscleChest: "Груди", muscleBack: "Спина", muscleShoulders: "Плечі",
        muscleBiceps: "Біцепс", muscleTriceps: "Трицепс", muscleLegs: "Ноги",
        muscleAbs: "Прес", muscleCardio: "Кардіо", muscleOther: "Інше",
        cardioBefore: "Кардіо перед тренуванням", cardioAfter: "Кардіо після тренування",
        cardioTime: "Час",
        cycleSize: "Розмір циклу", cycleSizeGlobal: "Тренувань у циклі (за замовч.)",
        cycleSizeOverride: "Розмір циклу для цього тижня",
        cycleSizeOverrideHelp: "Залиш порожнім щоб використати глобальний",
        cycle: "Цикл", currentCycle: "Поточний цикл", previousCycle: "Попередній цикл",
        cycleComparison: "Порівняння циклів", totalTonnageChange: "Зміна загального тоннажу",
        exercisesImproved: "Покращено", exercisesDeclined: "Знижено", exercisesNoChange: "Без змін",
        needMoreCyclesToCompare: "Потрібно щонайменше 2 завершені цикли",
        needMoreCyclesHint: "Закінчи більше тренувань щоб побачити прогрес",
        noCommonExercises: "Немає спільних вправ між циклами",
        progressByExercise: "По вправах", progressByCycles: "По циклах",
        weightProgressed: "Збільшено вагу", repsProgressed: "Збільшено повтори",
        tonnageProgressed: "Збільшено обсяг", noChange: "Без змін",
        restTimer: "Таймер відпочинку", restAfterSet: "Відпочинок після підходу",
        timerSound: "Звук таймера",
        soundBeep: "Сигнал", soundBell: "Дзвіночок", soundChime: "Мелодія",
        soundDing: "Дзень", soundNone: "Без звуку",
        preview: "Прослухати", vibration: "Вібрація",
        defaultRestTime: "Час відпочинку за замовч.",
        stopTimer: "Зупинити", restCustom: "Інший час"
    )
    
    static let en = Strings(
        weeks: "Weeks", week: "Week", workouts: "Workouts", workout: "Workout",
        progress: "Progress", bodyWeight: "My weight", settings: "Settings",
        addWeek: "Add week", addWorkout: "Add workout", addExercise: "Add exercise",
        addBlock: "Add divider", addCardio: "Add cardio",
        duplicate: "Duplicate", delete: "Delete", cancel: "Cancel", save: "Save",
        done: "Done", edit: "Edit",
        rename: "Rename", renameNumber: "Change number", renameName: "Change name",
        weekNumber: "Week number", workoutNumber: "Workout number",
        nameOptional: "Name (optional)", tonnage: "Tonnage", kg: "kg", lb: "lb",
        reps: "reps", weight: "Weight", sets: "Sets", minutes: "minutes", min: "min", sec: "sec",
        notesPlaceholder: "How was the workout? What to improve next time?",
        notesTitle: "Notes", blockName: "Section name", blockNamePlaceholder: "e.g. Chest, Legs",
        noWeeksYet: "It's empty here.\nAdd your first week.",
        noWorkoutsYet: "No workouts in this week yet.",
        noExercisesYet: "No exercises in this workout yet.",
        maxWorkoutsReached: "Maximum 14 workouts per week",
        maxExercisesReached: "Maximum 10 exercises per workout",
        maxSetsReached: "Maximum 10 sets per exercise",
        maxCardioReached: "Maximum 3 cardio items",
        chooseLanguage: "Choose your language", chooseLanguageSubtitle: "Оберіть мову",
        confirmDelete: "Confirm",
        deleteWeekMessage: "Delete this week with all its workouts?",
        deleteWorkoutMessage: "Delete this workout?",
        deleteExerciseMessage: "Delete this exercise?",
        exercises: "exercises", date: "Date",
        exerciseLibrary: "Exercise library", cardioLibrary: "Cardio library",
        searchExercises: "Search exercise…", searchCardio: "Search cardio…",
        alphabetical: "Alphabetical", byMuscleGroup: "By group", allGroups: "All",
        myExercises: "My exercises", addCustomExercise: "Add custom exercise",
        addCustomCardio: "Add custom cardio",
        useThisExercise: "Select", exerciseName: "Exercise name", cardioName: "Cardio name",
        muscleGroup: "Muscle group", nothingFound: "Nothing found",
        createAsCustom: "Create as new exercise",
        muscleChest: "Chest", muscleBack: "Back", muscleShoulders: "Shoulders",
        muscleBiceps: "Biceps", muscleTriceps: "Triceps", muscleLegs: "Legs",
        muscleAbs: "Abs", muscleCardio: "Cardio", muscleOther: "Other",
        cardioBefore: "Cardio before workout", cardioAfter: "Cardio after workout",
        cardioTime: "Time",
        cycleSize: "Cycle size", cycleSizeGlobal: "Workouts per cycle (default)",
        cycleSizeOverride: "Cycle size for this week",
        cycleSizeOverrideHelp: "Leave empty to use the default",
        cycle: "Cycle", currentCycle: "Current cycle", previousCycle: "Previous cycle",
        cycleComparison: "Cycle comparison", totalTonnageChange: "Total tonnage change",
        exercisesImproved: "Improved", exercisesDeclined: "Declined", exercisesNoChange: "No change",
        needMoreCyclesToCompare: "At least 2 completed cycles required",
        needMoreCyclesHint: "Complete more workouts to see progress",
        noCommonExercises: "No common exercises between cycles",
        progressByExercise: "By exercise", progressByCycles: "By cycles",
        weightProgressed: "Weight increased", repsProgressed: "Reps increased",
        tonnageProgressed: "Volume increased", noChange: "No change",
        restTimer: "Rest timer", restAfterSet: "Rest after set",
        timerSound: "Timer sound",
        soundBeep: "Beep", soundBell: "Bell", soundChime: "Chime",
        soundDing: "Ding", soundNone: "Silent",
        preview: "Preview", vibration: "Vibration",
        defaultRestTime: "Default rest time",
        stopTimer: "Stop", restCustom: "Custom"
    )
    
    static let ru = Strings(
        weeks: "Недели", week: "Неделя", workouts: "Тренировки", workout: "Тренировка",
        progress: "Прогресс", bodyWeight: "Мой вес", settings: "Настройки",
        addWeek: "Добавить неделю", addWorkout: "Добавить тренировку", addExercise: "Добавить упражнение",
        addBlock: "Добавить разделитель", addCardio: "Добавить кардио",
        duplicate: "Дублировать", delete: "Удалить", cancel: "Отмена", save: "Сохранить",
        done: "Готово", edit: "Изменить",
        rename: "Переименовать", renameNumber: "Изменить номер", renameName: "Изменить название",
        weekNumber: "Номер недели", workoutNumber: "Номер тренировки",
        nameOptional: "Название (необязательно)", tonnage: "Тоннаж", kg: "кг", lb: "фунт",
        reps: "повторов", weight: "Вес", sets: "Подходы", minutes: "минут", min: "мин", sec: "сек",
        notesPlaceholder: "Как прошла тренировка? Что улучшить в следующий раз?",
        notesTitle: "Комментарий", blockName: "Название раздела", blockNamePlaceholder: "Напр. Грудь, Ноги",
        noWeeksYet: "Тут пока пусто.\nДобавь свою первую неделю.",
        noWorkoutsYet: "На этой неделе ещё нет тренировок.",
        noExercisesYet: "В этой тренировке ещё нет упражнений.",
        maxWorkoutsReached: "Максимум 14 тренировок в неделю",
        maxExercisesReached: "Максимум 10 упражнений в тренировке",
        maxSetsReached: "Максимум 10 подходов в упражнении",
        maxCardioReached: "Максимум 3 кардио",
        chooseLanguage: "Выберите язык", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Подтверждение",
        deleteWeekMessage: "Удалить эту неделю со всеми тренировками?",
        deleteWorkoutMessage: "Удалить эту тренировку?",
        deleteExerciseMessage: "Удалить это упражнение?",
        exercises: "упражнений", date: "Дата",
        exerciseLibrary: "База упражнений", cardioLibrary: "База кардио",
        searchExercises: "Поиск упражнения…", searchCardio: "Поиск кардио…",
        alphabetical: "По алфавиту", byMuscleGroup: "По группам", allGroups: "Все",
        myExercises: "Мои упражнения", addCustomExercise: "Добавить своё упражнение",
        addCustomCardio: "Добавить своё кардио",
        useThisExercise: "Выбрать", exerciseName: "Название упражнения", cardioName: "Название кардио",
        muscleGroup: "Мышечная группа", nothingFound: "Ничего не найдено",
        createAsCustom: "Создать как новое упражнение",
        muscleChest: "Грудь", muscleBack: "Спина", muscleShoulders: "Плечи",
        muscleBiceps: "Бицепс", muscleTriceps: "Трицепс", muscleLegs: "Ноги",
        muscleAbs: "Пресс", muscleCardio: "Кардио", muscleOther: "Другое",
        cardioBefore: "Кардио перед тренировкой", cardioAfter: "Кардио после тренировки",
        cardioTime: "Время",
        cycleSize: "Размер цикла", cycleSizeGlobal: "Тренировок в цикле (по умолч.)",
        cycleSizeOverride: "Размер цикла для этой недели",
        cycleSizeOverrideHelp: "Оставь пустым для использования по умолчанию",
        cycle: "Цикл", currentCycle: "Текущий цикл", previousCycle: "Предыдущий цикл",
        cycleComparison: "Сравнение циклов", totalTonnageChange: "Изменение общего тоннажа",
        exercisesImproved: "Улучшено", exercisesDeclined: "Снижено", exercisesNoChange: "Без изменений",
        needMoreCyclesToCompare: "Нужно минимум 2 завершённых цикла",
        needMoreCyclesHint: "Заверши больше тренировок чтобы увидеть прогресс",
        noCommonExercises: "Нет общих упражнений между циклами",
        progressByExercise: "По упражнениям", progressByCycles: "По циклам",
        weightProgressed: "Вес увеличен", repsProgressed: "Повторы увеличены",
        tonnageProgressed: "Объём увеличен", noChange: "Без изменений",
        restTimer: "Таймер отдыха", restAfterSet: "Отдых после подхода",
        timerSound: "Звук таймера",
        soundBeep: "Сигнал", soundBell: "Колокольчик", soundChime: "Мелодия",
        soundDing: "Динь", soundNone: "Без звука",
        preview: "Прослушать", vibration: "Вибрация",
        defaultRestTime: "Время отдыха по умолч.",
        stopTimer: "Остановить", restCustom: "Своё время"
    )
    
    static let es = Strings(
        weeks: "Semanas", week: "Semana", workouts: "Entrenamientos", workout: "Entrenamiento",
        progress: "Progreso", bodyWeight: "Mi peso", settings: "Ajustes",
        addWeek: "Añadir semana", addWorkout: "Añadir entrenamiento", addExercise: "Añadir ejercicio",
        addBlock: "Añadir separador", addCardio: "Añadir cardio",
        duplicate: "Duplicar", delete: "Eliminar", cancel: "Cancelar", save: "Guardar",
        done: "Listo", edit: "Editar",
        rename: "Renombrar", renameNumber: "Cambiar número", renameName: "Cambiar nombre",
        weekNumber: "Número de semana", workoutNumber: "Número de entrenamiento",
        nameOptional: "Nombre (opcional)", tonnage: "Tonelaje", kg: "kg", lb: "lb",
        reps: "reps", weight: "Peso", sets: "Series", minutes: "minutos", min: "min", sec: "seg",
        notesPlaceholder: "¿Cómo fue? ¿Qué mejorar la próxima vez?",
        notesTitle: "Notas", blockName: "Nombre de sección", blockNamePlaceholder: "ej. Pecho, Piernas",
        noWeeksYet: "Está vacío aquí.\nAñade tu primera semana.",
        noWorkoutsYet: "No hay entrenamientos en esta semana.",
        noExercisesYet: "No hay ejercicios en este entrenamiento.",
        maxWorkoutsReached: "Máximo 14 entrenamientos por semana",
        maxExercisesReached: "Máximo 10 ejercicios por entrenamiento",
        maxSetsReached: "Máximo 10 series por ejercicio",
        maxCardioReached: "Máximo 3 cardios",
        chooseLanguage: "Elige tu idioma", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Confirmar",
        deleteWeekMessage: "¿Eliminar esta semana con todos sus entrenamientos?",
        deleteWorkoutMessage: "¿Eliminar este entrenamiento?",
        deleteExerciseMessage: "¿Eliminar este ejercicio?",
        exercises: "ejercicios", date: "Fecha",
        exerciseLibrary: "Biblioteca de ejercicios", cardioLibrary: "Biblioteca de cardio",
        searchExercises: "Buscar ejercicio…", searchCardio: "Buscar cardio…",
        alphabetical: "Alfabético", byMuscleGroup: "Por grupo", allGroups: "Todos",
        myExercises: "Mis ejercicios", addCustomExercise: "Añadir ejercicio personalizado",
        addCustomCardio: "Añadir cardio personalizado",
        useThisExercise: "Seleccionar", exerciseName: "Nombre del ejercicio", cardioName: "Nombre del cardio",
        muscleGroup: "Grupo muscular", nothingFound: "No se encontró nada",
        createAsCustom: "Crear como ejercicio nuevo",
        muscleChest: "Pecho", muscleBack: "Espalda", muscleShoulders: "Hombros",
        muscleBiceps: "Bíceps", muscleTriceps: "Tríceps", muscleLegs: "Piernas",
        muscleAbs: "Abdominales", muscleCardio: "Cardio", muscleOther: "Otros",
        cardioBefore: "Cardio antes del entrenamiento", cardioAfter: "Cardio después del entrenamiento",
        cardioTime: "Tiempo",
        cycleSize: "Tamaño del ciclo", cycleSizeGlobal: "Entrenamientos por ciclo",
        cycleSizeOverride: "Tamaño para esta semana",
        cycleSizeOverrideHelp: "Deja vacío para usar el predeterminado",
        cycle: "Ciclo", currentCycle: "Ciclo actual", previousCycle: "Ciclo anterior",
        cycleComparison: "Comparación de ciclos", totalTonnageChange: "Cambio de tonelaje",
        exercisesImproved: "Mejorados", exercisesDeclined: "Disminuidos", exercisesNoChange: "Sin cambios",
        needMoreCyclesToCompare: "Se requieren al menos 2 ciclos completados",
        needMoreCyclesHint: "Completa más entrenamientos",
        noCommonExercises: "No hay ejercicios en común",
        progressByExercise: "Por ejercicio", progressByCycles: "Por ciclos",
        weightProgressed: "Peso aumentado", repsProgressed: "Repeticiones aumentadas",
        tonnageProgressed: "Volumen aumentado", noChange: "Sin cambios",
        restTimer: "Temporizador de descanso", restAfterSet: "Descanso tras serie",
        timerSound: "Sonido del temporizador",
        soundBeep: "Pitido", soundBell: "Campana", soundChime: "Carillón",
        soundDing: "Ding", soundNone: "Silencio",
        preview: "Probar", vibration: "Vibración",
        defaultRestTime: "Descanso predeterminado",
        stopTimer: "Detener", restCustom: "Personalizado"
    )
    
    static let de = Strings(
        weeks: "Wochen", week: "Woche", workouts: "Trainings", workout: "Training",
        progress: "Fortschritt", bodyWeight: "Mein Gewicht", settings: "Einstellungen",
        addWeek: "Woche hinzufügen", addWorkout: "Training hinzufügen", addExercise: "Übung hinzufügen",
        addBlock: "Trennlinie hinzufügen", addCardio: "Cardio hinzufügen",
        duplicate: "Duplizieren", delete: "Löschen", cancel: "Abbrechen", save: "Speichern",
        done: "Fertig", edit: "Bearbeiten",
        rename: "Umbenennen", renameNumber: "Nummer ändern", renameName: "Namen ändern",
        weekNumber: "Wochennummer", workoutNumber: "Trainingsnummer",
        nameOptional: "Name (optional)", tonnage: "Tonnage", kg: "kg", lb: "lb",
        reps: "Wdh", weight: "Gewicht", sets: "Sätze", minutes: "Minuten", min: "Min", sec: "Sek",
        notesPlaceholder: "Wie war das Training? Was nächstes Mal verbessern?",
        notesTitle: "Notizen", blockName: "Abschnittsname", blockNamePlaceholder: "z. B. Brust, Beine",
        noWeeksYet: "Hier ist es leer.\nFüge deine erste Woche hinzu.",
        noWorkoutsYet: "Noch keine Trainings.",
        noExercisesYet: "Noch keine Übungen.",
        maxWorkoutsReached: "Maximal 14 Trainings pro Woche",
        maxExercisesReached: "Maximal 10 Übungen pro Training",
        maxSetsReached: "Maximal 10 Sätze pro Übung",
        maxCardioReached: "Maximal 3 Cardio-Einträge",
        chooseLanguage: "Wähle deine Sprache", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Bestätigen",
        deleteWeekMessage: "Diese Woche mit allen Trainings löschen?",
        deleteWorkoutMessage: "Dieses Training löschen?",
        deleteExerciseMessage: "Diese Übung löschen?",
        exercises: "Übungen", date: "Datum",
        exerciseLibrary: "Übungsbibliothek", cardioLibrary: "Cardio-Bibliothek",
        searchExercises: "Übung suchen…", searchCardio: "Cardio suchen…",
        alphabetical: "Alphabetisch", byMuscleGroup: "Nach Gruppe", allGroups: "Alle",
        myExercises: "Meine Übungen", addCustomExercise: "Eigene Übung hinzufügen",
        addCustomCardio: "Eigenes Cardio hinzufügen",
        useThisExercise: "Auswählen", exerciseName: "Übungsname", cardioName: "Cardio-Name",
        muscleGroup: "Muskelgruppe", nothingFound: "Nichts gefunden",
        createAsCustom: "Als neue Übung erstellen",
        muscleChest: "Brust", muscleBack: "Rücken", muscleShoulders: "Schultern",
        muscleBiceps: "Bizeps", muscleTriceps: "Trizeps", muscleLegs: "Beine",
        muscleAbs: "Bauch", muscleCardio: "Cardio", muscleOther: "Andere",
        cardioBefore: "Cardio vor dem Training", cardioAfter: "Cardio nach dem Training",
        cardioTime: "Zeit",
        cycleSize: "Zyklusgröße", cycleSizeGlobal: "Trainings pro Zyklus (Standard)",
        cycleSizeOverride: "Zyklusgröße für diese Woche",
        cycleSizeOverrideHelp: "Leer lassen für Standard",
        cycle: "Zyklus", currentCycle: "Aktueller Zyklus", previousCycle: "Vorheriger Zyklus",
        cycleComparison: "Zyklusvergleich", totalTonnageChange: "Veränderung Gesamttonnage",
        exercisesImproved: "Verbessert", exercisesDeclined: "Verschlechtert", exercisesNoChange: "Unverändert",
        needMoreCyclesToCompare: "Mindestens 2 abgeschlossene Zyklen erforderlich",
        needMoreCyclesHint: "Schließe mehr Trainings ab",
        noCommonExercises: "Keine gemeinsamen Übungen",
        progressByExercise: "Nach Übung", progressByCycles: "Nach Zyklen",
        weightProgressed: "Gewicht erhöht", repsProgressed: "Wdh erhöht",
        tonnageProgressed: "Volumen erhöht", noChange: "Keine Änderung",
        restTimer: "Pausentimer", restAfterSet: "Pause nach Satz",
        timerSound: "Timer-Sound",
        soundBeep: "Piep", soundBell: "Glocke", soundChime: "Glockenspiel",
        soundDing: "Ding", soundNone: "Stumm",
        preview: "Anhören", vibration: "Vibration",
        defaultRestTime: "Standard-Pausenzeit",
        stopTimer: "Stoppen", restCustom: "Benutzerdef."
    )
    
    static let fr = Strings(
        weeks: "Semaines", week: "Semaine", workouts: "Entraînements", workout: "Entraînement",
        progress: "Progrès", bodyWeight: "Mon poids", settings: "Réglages",
        addWeek: "Ajouter une semaine", addWorkout: "Ajouter un entraînement", addExercise: "Ajouter un exercice",
        addBlock: "Ajouter un séparateur", addCardio: "Ajouter un cardio",
        duplicate: "Dupliquer", delete: "Supprimer", cancel: "Annuler", save: "Enregistrer",
        done: "Terminé", edit: "Modifier",
        rename: "Renommer", renameNumber: "Changer le numéro", renameName: "Changer le nom",
        weekNumber: "Numéro de semaine", workoutNumber: "Numéro d'entraînement",
        nameOptional: "Nom (facultatif)", tonnage: "Tonnage", kg: "kg", lb: "lb",
        reps: "réps", weight: "Poids", sets: "Séries", minutes: "minutes", min: "min", sec: "sec",
        notesPlaceholder: "Comment s'est passé l'entraînement ?",
        notesTitle: "Notes", blockName: "Nom de section", blockNamePlaceholder: "ex. Poitrine, Jambes",
        noWeeksYet: "C'est vide ici.\nAjoute ta première semaine.",
        noWorkoutsYet: "Aucun entraînement.",
        noExercisesYet: "Aucun exercice.",
        maxWorkoutsReached: "Maximum 14 entraînements par semaine",
        maxExercisesReached: "Maximum 10 exercices par entraînement",
        maxSetsReached: "Maximum 10 séries par exercice",
        maxCardioReached: "Maximum 3 cardios",
        chooseLanguage: "Choisis ta langue", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Confirmer",
        deleteWeekMessage: "Supprimer cette semaine et tous ses entraînements?",
        deleteWorkoutMessage: "Supprimer cet entraînement?",
        deleteExerciseMessage: "Supprimer cet exercice?",
        exercises: "exercices", date: "Date",
        exerciseLibrary: "Bibliothèque d'exercices", cardioLibrary: "Bibliothèque cardio",
        searchExercises: "Rechercher un exercice…", searchCardio: "Rechercher un cardio…",
        alphabetical: "Alphabétique", byMuscleGroup: "Par groupe", allGroups: "Tous",
        myExercises: "Mes exercices", addCustomExercise: "Ajouter un exercice perso",
        addCustomCardio: "Ajouter un cardio perso",
        useThisExercise: "Sélectionner", exerciseName: "Nom de l'exercice", cardioName: "Nom du cardio",
        muscleGroup: "Groupe musculaire", nothingFound: "Rien trouvé",
        createAsCustom: "Créer comme nouvel exercice",
        muscleChest: "Poitrine", muscleBack: "Dos", muscleShoulders: "Épaules",
        muscleBiceps: "Biceps", muscleTriceps: "Triceps", muscleLegs: "Jambes",
        muscleAbs: "Abdos", muscleCardio: "Cardio", muscleOther: "Autres",
        cardioBefore: "Cardio avant", cardioAfter: "Cardio après",
        cardioTime: "Temps",
        cycleSize: "Taille du cycle", cycleSizeGlobal: "Entraînements par cycle (défaut)",
        cycleSizeOverride: "Taille pour cette semaine",
        cycleSizeOverrideHelp: "Vide pour utiliser la valeur par défaut",
        cycle: "Cycle", currentCycle: "Cycle actuel", previousCycle: "Cycle précédent",
        cycleComparison: "Comparaison des cycles", totalTonnageChange: "Changement du tonnage",
        exercisesImproved: "Améliorés", exercisesDeclined: "En baisse", exercisesNoChange: "Sans changement",
        needMoreCyclesToCompare: "Au moins 2 cycles complets requis",
        needMoreCyclesHint: "Termine plus d'entraînements",
        noCommonExercises: "Pas d'exercices communs",
        progressByExercise: "Par exercice", progressByCycles: "Par cycles",
        weightProgressed: "Poids augmenté", repsProgressed: "Répétitions augmentées",
        tonnageProgressed: "Volume augmenté", noChange: "Sans changement",
        restTimer: "Minuteur de repos", restAfterSet: "Repos après série",
        timerSound: "Son du minuteur",
        soundBeep: "Bip", soundBell: "Cloche", soundChime: "Carillon",
        soundDing: "Ding", soundNone: "Silencieux",
        preview: "Tester", vibration: "Vibration",
        defaultRestTime: "Temps de repos par défaut",
        stopTimer: "Arrêter", restCustom: "Personnalisé"
    )
    
    static let pt = Strings(
        weeks: "Semanas", week: "Semana", workouts: "Treinos", workout: "Treino",
        progress: "Progresso", bodyWeight: "Meu peso", settings: "Configurações",
        addWeek: "Adicionar semana", addWorkout: "Adicionar treino", addExercise: "Adicionar exercício",
        addBlock: "Adicionar separador", addCardio: "Adicionar cardio",
        duplicate: "Duplicar", delete: "Excluir", cancel: "Cancelar", save: "Salvar",
        done: "Pronto", edit: "Editar",
        rename: "Renomear", renameNumber: "Mudar número", renameName: "Mudar nome",
        weekNumber: "Número da semana", workoutNumber: "Número do treino",
        nameOptional: "Nome (opcional)", tonnage: "Tonelagem", kg: "kg", lb: "lb",
        reps: "reps", weight: "Peso", sets: "Séries", minutes: "minutos", min: "min", sec: "seg",
        notesPlaceholder: "Como foi o treino?",
        notesTitle: "Notas", blockName: "Nome da seção", blockNamePlaceholder: "ex. Peito, Pernas",
        noWeeksYet: "Está vazio aqui.\nAdicione sua primeira semana.",
        noWorkoutsYet: "Sem treinos.",
        noExercisesYet: "Sem exercícios.",
        maxWorkoutsReached: "Máximo 14 treinos por semana",
        maxExercisesReached: "Máximo 10 exercícios por treino",
        maxSetsReached: "Máximo 10 séries por exercício",
        maxCardioReached: "Máximo 3 cardios",
        chooseLanguage: "Escolha seu idioma", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Confirmar",
        deleteWeekMessage: "Excluir esta semana com todos os treinos?",
        deleteWorkoutMessage: "Excluir este treino?",
        deleteExerciseMessage: "Excluir este exercício?",
        exercises: "exercícios", date: "Data",
        exerciseLibrary: "Biblioteca de exercícios", cardioLibrary: "Biblioteca de cardio",
        searchExercises: "Buscar exercício…", searchCardio: "Buscar cardio…",
        alphabetical: "Alfabético", byMuscleGroup: "Por grupo", allGroups: "Todos",
        myExercises: "Meus exercícios", addCustomExercise: "Adicionar exercício personalizado",
        addCustomCardio: "Adicionar cardio personalizado",
        useThisExercise: "Selecionar", exerciseName: "Nome do exercício", cardioName: "Nome do cardio",
        muscleGroup: "Grupo muscular", nothingFound: "Nada encontrado",
        createAsCustom: "Criar como novo exercício",
        muscleChest: "Peito", muscleBack: "Costas", muscleShoulders: "Ombros",
        muscleBiceps: "Bíceps", muscleTriceps: "Tríceps", muscleLegs: "Pernas",
        muscleAbs: "Abdômen", muscleCardio: "Cardio", muscleOther: "Outros",
        cardioBefore: "Cardio antes", cardioAfter: "Cardio depois",
        cardioTime: "Tempo",
        cycleSize: "Tamanho do ciclo", cycleSizeGlobal: "Treinos por ciclo (padrão)",
        cycleSizeOverride: "Tamanho para esta semana",
        cycleSizeOverrideHelp: "Vazio para usar o padrão",
        cycle: "Ciclo", currentCycle: "Ciclo atual", previousCycle: "Ciclo anterior",
        cycleComparison: "Comparação de ciclos", totalTonnageChange: "Variação da tonelagem",
        exercisesImproved: "Melhorados", exercisesDeclined: "Reduzidos", exercisesNoChange: "Sem mudança",
        needMoreCyclesToCompare: "São necessários pelo menos 2 ciclos completos",
        needMoreCyclesHint: "Complete mais treinos",
        noCommonExercises: "Não há exercícios em comum",
        progressByExercise: "Por exercício", progressByCycles: "Por ciclos",
        weightProgressed: "Peso aumentado", repsProgressed: "Reps aumentadas",
        tonnageProgressed: "Volume aumentado", noChange: "Sem mudança",
        restTimer: "Cronômetro de descanso", restAfterSet: "Descanso após série",
        timerSound: "Som do cronômetro",
        soundBeep: "Beep", soundBell: "Sino", soundChime: "Carrilhão",
        soundDing: "Ding", soundNone: "Silencioso",
        preview: "Ouvir", vibration: "Vibração",
        defaultRestTime: "Tempo de descanso padrão",
        stopTimer: "Parar", restCustom: "Personalizado"
    )
    
    static let pl = Strings(
        weeks: "Tygodnie", week: "Tydzień", workouts: "Treningi", workout: "Trening",
        progress: "Postęp", bodyWeight: "Moja waga", settings: "Ustawienia",
        addWeek: "Dodaj tydzień", addWorkout: "Dodaj trening", addExercise: "Dodaj ćwiczenie",
        addBlock: "Dodaj separator", addCardio: "Dodaj kardio",
        duplicate: "Duplikuj", delete: "Usuń", cancel: "Anuluj", save: "Zapisz",
        done: "Gotowe", edit: "Edytuj",
        rename: "Zmień nazwę", renameNumber: "Zmień numer", renameName: "Zmień nazwę",
        weekNumber: "Numer tygodnia", workoutNumber: "Numer treningu",
        nameOptional: "Nazwa (opcjonalnie)", tonnage: "Tonaż", kg: "kg", lb: "lb",
        reps: "powt.", weight: "Ciężar", sets: "Serie", minutes: "minut", min: "min", sec: "sek",
        notesPlaceholder: "Jak poszło?",
        notesTitle: "Notatki", blockName: "Nazwa sekcji", blockNamePlaceholder: "np. Klatka, Nogi",
        noWeeksYet: "Tu jest pusto.\nDodaj swój pierwszy tydzień.",
        noWorkoutsYet: "Brak treningów.",
        noExercisesYet: "Brak ćwiczeń.",
        maxWorkoutsReached: "Maksymalnie 14 treningów tygodniowo",
        maxExercisesReached: "Maksymalnie 10 ćwiczeń na trening",
        maxSetsReached: "Maksymalnie 10 serii na ćwiczenie",
        maxCardioReached: "Maksymalnie 3 kardio",
        chooseLanguage: "Wybierz język", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Potwierdzenie",
        deleteWeekMessage: "Usunąć ten tydzień ze wszystkimi treningami?",
        deleteWorkoutMessage: "Usunąć ten trening?",
        deleteExerciseMessage: "Usunąć to ćwiczenie?",
        exercises: "ćwiczeń", date: "Data",
        exerciseLibrary: "Baza ćwiczeń", cardioLibrary: "Baza kardio",
        searchExercises: "Szukaj ćwiczenia…", searchCardio: "Szukaj kardio…",
        alphabetical: "Alfabetycznie", byMuscleGroup: "Wg grupy", allGroups: "Wszystkie",
        myExercises: "Moje ćwiczenia", addCustomExercise: "Dodaj własne ćwiczenie",
        addCustomCardio: "Dodaj własne kardio",
        useThisExercise: "Wybierz", exerciseName: "Nazwa ćwiczenia", cardioName: "Nazwa kardio",
        muscleGroup: "Grupa mięśniowa", nothingFound: "Nic nie znaleziono",
        createAsCustom: "Utwórz jako nowe ćwiczenie",
        muscleChest: "Klatka", muscleBack: "Plecy", muscleShoulders: "Barki",
        muscleBiceps: "Biceps", muscleTriceps: "Triceps", muscleLegs: "Nogi",
        muscleAbs: "Brzuch", muscleCardio: "Kardio", muscleOther: "Inne",
        cardioBefore: "Kardio przed", cardioAfter: "Kardio po",
        cardioTime: "Czas",
        cycleSize: "Rozmiar cyklu", cycleSizeGlobal: "Treningi w cyklu (domyślnie)",
        cycleSizeOverride: "Rozmiar dla tego tygodnia",
        cycleSizeOverrideHelp: "Pozostaw puste dla domyślnego",
        cycle: "Cykl", currentCycle: "Bieżący cykl", previousCycle: "Poprzedni cykl",
        cycleComparison: "Porównanie cykli", totalTonnageChange: "Zmiana tonażu",
        exercisesImproved: "Poprawione", exercisesDeclined: "Pogorszone", exercisesNoChange: "Bez zmian",
        needMoreCyclesToCompare: "Wymagane co najmniej 2 ukończone cykle",
        needMoreCyclesHint: "Ukończ więcej treningów",
        noCommonExercises: "Brak wspólnych ćwiczeń",
        progressByExercise: "Wg ćwiczenia", progressByCycles: "Wg cykli",
        weightProgressed: "Zwiększony ciężar", repsProgressed: "Zwiększone powt.",
        tonnageProgressed: "Zwiększona objętość", noChange: "Bez zmian",
        restTimer: "Stoper odpoczynku", restAfterSet: "Odpoczynek po serii",
        timerSound: "Dźwięk stopera",
        soundBeep: "Sygnał", soundBell: "Dzwonek", soundChime: "Dzwonki",
        soundDing: "Ding", soundNone: "Cisza",
        preview: "Posłuchaj", vibration: "Wibracja",
        defaultRestTime: "Domyślny czas odpoczynku",
        stopTimer: "Zatrzymaj", restCustom: "Własny"
    )
    
    static let it = Strings(
        weeks: "Settimane", week: "Settimana", workouts: "Allenamenti", workout: "Allenamento",
        progress: "Progressi", bodyWeight: "Il mio peso", settings: "Impostazioni",
        addWeek: "Aggiungi settimana", addWorkout: "Aggiungi allenamento", addExercise: "Aggiungi esercizio",
        addBlock: "Aggiungi separatore", addCardio: "Aggiungi cardio",
        duplicate: "Duplica", delete: "Elimina", cancel: "Annulla", save: "Salva",
        done: "Fatto", edit: "Modifica",
        rename: "Rinomina", renameNumber: "Cambia numero", renameName: "Cambia nome",
        weekNumber: "Numero settimana", workoutNumber: "Numero allenamento",
        nameOptional: "Nome (facoltativo)", tonnage: "Tonnellaggio", kg: "kg", lb: "lb",
        reps: "rip", weight: "Peso", sets: "Serie", minutes: "minuti", min: "min", sec: "sec",
        notesPlaceholder: "Com'è andato?",
        notesTitle: "Note", blockName: "Nome sezione", blockNamePlaceholder: "es. Petto, Gambe",
        noWeeksYet: "È vuoto qui.\nAggiungi la tua prima settimana.",
        noWorkoutsYet: "Nessun allenamento.",
        noExercisesYet: "Nessun esercizio.",
        maxWorkoutsReached: "Massimo 14 allenamenti a settimana",
        maxExercisesReached: "Massimo 10 esercizi per allenamento",
        maxSetsReached: "Massimo 10 serie per esercizio",
        maxCardioReached: "Massimo 3 cardio",
        chooseLanguage: "Scegli la lingua", chooseLanguageSubtitle: "Choose your language",
        confirmDelete: "Conferma",
        deleteWeekMessage: "Eliminare questa settimana con tutti gli allenamenti?",
        deleteWorkoutMessage: "Eliminare questo allenamento?",
        deleteExerciseMessage: "Eliminare questo esercizio?",
        exercises: "esercizi", date: "Data",
        exerciseLibrary: "Libreria esercizi", cardioLibrary: "Libreria cardio",
        searchExercises: "Cerca esercizio…", searchCardio: "Cerca cardio…",
        alphabetical: "Alfabetico", byMuscleGroup: "Per gruppo", allGroups: "Tutti",
        myExercises: "I miei esercizi", addCustomExercise: "Aggiungi esercizio personalizzato",
        addCustomCardio: "Aggiungi cardio personalizzato",
        useThisExercise: "Seleziona", exerciseName: "Nome dell'esercizio", cardioName: "Nome del cardio",
        muscleGroup: "Gruppo muscolare", nothingFound: "Niente trovato",
        createAsCustom: "Crea come nuovo esercizio",
        muscleChest: "Petto", muscleBack: "Schiena", muscleShoulders: "Spalle",
        muscleBiceps: "Bicipiti", muscleTriceps: "Tricipiti", muscleLegs: "Gambe",
        muscleAbs: "Addominali", muscleCardio: "Cardio", muscleOther: "Altri",
        cardioBefore: "Cardio prima", cardioAfter: "Cardio dopo",
        cardioTime: "Tempo",
        cycleSize: "Dimensione del ciclo", cycleSizeGlobal: "Allenamenti per ciclo (predefinito)",
        cycleSizeOverride: "Dimensione per questa settimana",
        cycleSizeOverrideHelp: "Vuoto per usare il predefinito",
        cycle: "Ciclo", currentCycle: "Ciclo attuale", previousCycle: "Ciclo precedente",
        cycleComparison: "Confronto cicli", totalTonnageChange: "Variazione tonnellaggio",
        exercisesImproved: "Migliorati", exercisesDeclined: "Peggiorati", exercisesNoChange: "Invariati",
        needMoreCyclesToCompare: "Richiesti almeno 2 cicli completati",
        needMoreCyclesHint: "Completa più allenamenti",
        noCommonExercises: "Nessun esercizio in comune",
        progressByExercise: "Per esercizio", progressByCycles: "Per cicli",
        weightProgressed: "Peso aumentato", repsProgressed: "Ripetizioni aumentate",
        tonnageProgressed: "Volume aumentato", noChange: "Nessun cambiamento",
        restTimer: "Timer di riposo", restAfterSet: "Riposo dopo serie",
        timerSound: "Suono del timer",
        soundBeep: "Bip", soundBell: "Campana", soundChime: "Carillon",
        soundDing: "Ding", soundNone: "Silenzioso",
        preview: "Ascolta", vibration: "Vibrazione",
        defaultRestTime: "Tempo di riposo predefinito",
        stopTimer: "Ferma", restCustom: "Personalizzato"
    )
    
    static func current(for language: AppLanguage?) -> Strings {
        switch language {
        case .en: return .en
        case .ru: return .ru
        case .es: return .es
        case .de: return .de
        case .fr: return .fr
        case .pt: return .pt
        case .pl: return .pl
        case .it: return .it
        default:  return .uk
        }
    }
    
    func muscleGroupName(_ group: MuscleGroup) -> String {
        switch group {
        case .chest: return muscleChest
        case .back: return muscleBack
        case .shoulders: return muscleShoulders
        case .biceps: return muscleBiceps
        case .triceps: return muscleTriceps
        case .legs: return muscleLegs
        case .abs: return muscleAbs
        case .cardio: return muscleCardio
        case .other: return muscleOther
        }
    }
    
    func soundName(_ sound: TimerSound) -> String {
        switch sound {
        case .beep: return soundBeep
        case .bell: return soundBell
        case .chime: return soundChime
        case .ding: return soundDing
        case .none: return soundNone
        }
    }
}

private struct StringsKey: EnvironmentKey {
    static let defaultValue: Strings = .uk
}

extension EnvironmentValues {
    var strings: Strings {
        get { self[StringsKey.self] }
        set { self[StringsKey.self] = newValue }
    }
}
