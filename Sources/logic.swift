
func Q1(cluster: Cluster) {
    for (node, pod, container) in cluster.getContainersFull() {
        if container.status == .running {
            print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) fonctionne normalement.")
        } else if container.status == .stopped {
            print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) est arrêté.")
        } else if container.status == .crashed {
            print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) a crashé.")
        }
    }
}

func Q2(cluster: Cluster) {
    for node in cluster.nodes {
        for pod in node.pods {
            var totalCpu = 0
            var totalRam = 0
            for container in pod.containers {
                totalCpu += container.cpu
                totalRam += container.ram
            }
            print("Le pod \(pod.id) sur le noeud \(node.id) utilise \(totalCpu) CPUs et \(totalRam) RAM.")
        }
    }
}

func Q3(cluster: Cluster) {
    var runningContainers = 0
    var stoppedContainers = 0
    var crashedContainers = 0

    for container in cluster.getContainers() {
        switch container.status {
        case .running:
            runningContainers += 1
        case .stopped:
            stoppedContainers += 1
        case .crashed:
            crashedContainers += 1
        default:
            break
        }
    }

    print("Résumé global du cluster:")
    print("Nombre total de conteneurs en cours d'exécution: \(runningContainers)")
    print("Nombre de conteneurs arrêtés: \(stoppedContainers)")
    print("Nombre de conteneurs crashés: \(crashedContainers)")
}

func Q4(cluster: Cluster) {
    for node in cluster.nodes {
        print("Le noeud \(node.id) a \(node.cpu) CPUs et \(node.ram) RAM disponibles.")
    }
}


struct RessourcesNeeded {
    var cpu: Int
    var ram: Int
}

func getRessourcesMaps() -> [String: RessourcesNeeded] {
    return [
        "postgres_db": RessourcesNeeded(cpu: 5, ram: 5),
        "redis_cache": RessourcesNeeded(cpu: 2, ram: 2),
        "kafka_broker": RessourcesNeeded(cpu: 50, ram: 50),
    ]
}

func Q5(cluster: Cluster) {
    for (node, _, container) in cluster.getContainersFull() {
        if container.status == .crashed {
            // Query needed ressources for this container
            let ressourcesMap = getRessourcesMaps()
            let ressourcesNeededOpt = ressourcesMap[container.name]
            if ressourcesNeededOpt == nil {
                print("Le conteneur \(container.name) a crashé mais nous ne connaissons pas les ressources qu'il demande.")
                continue
            }
            let ressourcesNeeded = ressourcesNeededOpt!

            // Query node used ressources
            var (usedCPU, usedRAM) = node.usedResources()
            
            // Calculate needed total node ressources to run the container
            usedCPU -= container.cpu
            usedRAM -= container.ram
            usedCPU += ressourcesNeeded.cpu
            usedRAM += ressourcesNeeded.ram

            // Check if node has enough ressources
            if usedCPU <= node.cpu && usedRAM <= node.ram {
                print("Le conteneur \(container.name) a crashé mais le noeud a suffisamment de ressources pour le redémarrer.")
                container.status = .running
            } else {
                print("Le conteneur \(container.name) a crashé et le noeud n'a pas suffisamment de ressources pour le redémarrer.")
            }
        }
    }
}

func Q6(cluster: Cluster, wantedType: String) {
    let containers = cluster.getContainers().filter({ container in
        return container.name == wantedType
    })

    print("Nombre de conteneurs de type \(wantedType): \(containers.count)")
}

func Q7(cluster: Cluster, wantedType: String) {
    let containers = cluster.getContainers().filter({ container in
        return container.name == wantedType
    })

    var totalCpu = 0
    var totalRam = 0
    for container in containers {
        totalCpu += container.cpu
        totalRam += container.ram
    }

    print("Ressources totales utilisées par les conteneurs de type \(wantedType): \(totalCpu) CPUs et \(totalRam) RAM.")
}