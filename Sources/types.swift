class Cluster : CustomStringConvertible {
    var nodes: [Node]

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    var description: String {
        return "Cluster(nodes: \(nodes))"
    }

    func getContainers() -> [Container] {
        var containers = [Container]()
        for node in nodes {
            for pod in node.pods {
                containers.append(contentsOf: pod.containers)
            }
        }
        return containers
    }

    func getContainersFull() -> [(Node, Pod, Container)] {
        var containers = [(Node, Pod, Container)]()
        for node in nodes {
            for pod in node.pods {
                for container in pod.containers {
                    containers.append((node, pod, container))
                }
            }
        }
        return containers
    }
}

class Node : CustomStringConvertible {
    var id: Int
    var cpu: Int
    var ram: Int
    var pods: [Pod]

    init(id: Int, cpu: Int, ram: Int, pods: [Pod]) {
        self.id = id
        self.cpu = cpu
        self.ram = ram
        self.pods = pods
    }

    var description: String {
        return "Node(id: \(id), cpu: \(cpu), ram: \(ram), pods: \(pods))"
    }

    func usedResources() -> (Int, Int) {
        var usedCPU = 0
        var usedRAM = 0
        for pod in pods {
            for container in pod.containers {
                usedCPU += container.cpu
                usedRAM += container.ram
            }
        }
        return (usedCPU, usedRAM)
    }
    
}

class Pod : CustomStringConvertible {
    var id: Int
    var containers: [Container]

    init(id: Int, containers: [Container]) {
        self.id = id
        self.containers = containers
    }

    var description: String {
        return "Pod(id: \(id), containers: \(containers))"
    }
}

enum ContainerStatus: String, CustomStringConvertible {
    case running = "running"
    case stopped = "stopped"
    case crashed = "crashed"
    case unknown = "unknown"

    var description: String {
        return self.rawValue
    }
}

class Container : CustomStringConvertible {
    var name: String
    var status: ContainerStatus
    var cpu: Int
    var ram: Int

    init(name: String, status: ContainerStatus, cpu: Int, ram: Int) {
        self.name = name
        self.status = status
        self.cpu = cpu
        self.ram = ram
    }

    var description: String {
        return "Container(name: \(name), status: \(status), cpu: \(cpu), ram: \(ram))"
    }
}
