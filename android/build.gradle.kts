allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force tous les sous-projets (plugins Flutter) à compiler contre le SDK de base 36.
// Raison : les platforms de base android-33/34 ne sont plus distribués séparément
// par Google (seules les variantes "ext" subsistent, qu'AGP refuse comme base).
// compileSdk 36 est rétro-compatible — les plugins ciblant 33/34/35 compilent sans souci.
// gradle.projectsEvaluated : après évaluation de tous les projets, avant les tâches de build.
// Force tous les sous-projets (plugins Flutter) à compiler contre l'API 36.
// IMPORTANT : l'override doit se faire dans `afterEvaluate` PAR sous-projet —
// juste après l'évaluation du plugin, AVANT que l'AGP ne verrouille le DSL.
// (Le faire dans gradle.projectsEvaluated est trop tard : setCompileSdk jette.)
// On utilise la méthode legacy compileSdkVersion(int), non verrouillée à ce stade.
fun Project.forceCompileSdk36() {
    val androidExt = extensions.findByName("android") ?: return
    val methods = androidExt.javaClass.methods
    val intMethod = methods.firstOrNull {
        it.name == "compileSdkVersion" && it.parameterCount == 1 &&
            it.parameterTypes[0] == Int::class.javaPrimitiveType
    } ?: methods.firstOrNull {
        it.name == "setCompileSdk" && it.parameterCount == 1 &&
            (it.parameterTypes[0] == Integer::class.java ||
                it.parameterTypes[0] == Int::class.javaPrimitiveType)
    }
    try {
        if (intMethod != null) {
            intMethod.invoke(androidExt, 36)
        } else {
            logger.warn("compileSdk override : aucune méthode pour $name")
        }
    } catch (e: Exception) {
        logger.warn("compileSdk override échoué pour $name: ${(e.cause ?: e).message}")
    }
}

subprojects {
    // Certains sous-projets (ex. :app via evaluationDependsOn) sont déjà évalués
    // quand ce bloc s'exécute → afterEvaluate y est interdit. On configure alors
    // directement ; sinon on attend l'évaluation du plugin (avant verrouillage DSL).
    if (state.executed) {
        forceCompileSdk36()
    } else {
        afterEvaluate { forceCompileSdk36() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
