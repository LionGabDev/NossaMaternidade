//
//  PregnancyCalculator.swift
//  MamaVida
//

import Foundation

enum PregnancyCalculator {
    static func dueDate(from lmp: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 280, to: lmp) ?? lmp
    }

    static func currentWeek(from lmp: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: lmp, to: Date()).day ?? 0
        let week = (days / 7) + 1
        return min(max(week, 1), 42)
    }

    static func daysUntilDue(from dueDate: Date) -> Int {
        max(Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0, 0)
    }

    static func babySize(for week: Int) -> BabySizeInfo {
        BabySizeInfo.babySizes[min(max(week, 1), 42)] ?? BabySizeInfo(week: week, size: "Desconhecido", lengthCm: 0, weightG: 0, emoji: "👶")
    }

    static func tips(for week: Int) -> [String] {
        let allTips: [Int: [String]] = [
            1: ["Evite álcool e cigarros.", "Comece a tomar ácido fólico.", "Agende sua primeira consulta."],
            4: ["Cansaço é normal nos primeiros meses.", "Hidrate-se bastante.", "Descanse sempre que possível."],
            8: ["Suas náuseas devem melhorar em breve.", "Evite alimentos gordurosos.", "Faça refeições leves e frequentes."],
            12: ["O risco de aborto diminui muito agora.", "Você pode sentir mais energia.", "Mantenha os exercícios leves."],
            16: ["Você pode sentir os primeiros movimentos.", "Use protetor solar diariamente.", "Evite deitar de costas por muito tempo."],
            20: ["A ultrassom morfológica é importante.", "Sinta-se à vontade para comprar enxoval.", "Considere aulas de preparação."],
            24: ["Fique atenta à pressão arterial.", "Movimentos do bebê devem ser frequentes.", "Durma de lado, preferencialmente esquerdo."],
            28: ["Teste de glicemia é essencial.", "Cuidado com inchaços nas pernas.", "Prepare a mala da maternidade."],
            32: ["O bebê está ganhando peso rápido.", "Você pode sentir azia frequente.", "Evite sal em excesso."],
            36: ["O bebê já pode vir a qualquer momento.", "Descanse bastante.", "Revise o plano de parto com seu médico."],
            40: ["Poucos dias! Mantenha a calma.", "Aproveite para descansar.", "Ligue para o hospital se houver qualquer sinal."]
        ]
        return allTips[week] ?? allTips[24]!
    }
}

struct BabySizeInfo: Identifiable {
    let id = UUID()
    let week: Int
    let size: String
    let lengthCm: Int
    let weightG: Int
    let emoji: String

    static let babySizes: [Int: BabySizeInfo] = [
        1: BabySizeInfo(week: 1, size: "Semente de papoula", lengthCm: 0, weightG: 0, emoji: "🌱"),
        2: BabySizeInfo(week: 2, size: "Semente de mamão", lengthCm: 0, weightG: 0, emoji: "🌱"),
        3: BabySizeInfo(week: 3, size: "Lentilha", lengthCm: 0, weightG: 0, emoji: "🫘"),
        4: BabySizeInfo(week: 4, size: "Semente de romã", lengthCm: 0, weightG: 0, emoji: "🫘"),
        5: BabySizeInfo(week: 5, size: "Grão de arroz", lengthCm: 0, weightG: 0, emoji: "🍚"),
        6: BabySizeInfo(week: 6, size: "Ervilha", lengthCm: 0, weightG: 0, emoji: "🟢"),
        7: BabySizeInfo(week: 7, size: "Mirtilo", lengthCm: 1, weightG: 0, emoji: "🫐"),
        8: BabySizeInfo(week: 8, size: "Framboesa", lengthCm: 1, weightG: 1, emoji: "🍇"),
        9: BabySizeInfo(week: 9, size: "Azeitona", lengthCm: 2, weightG: 2, emoji: "🫒"),
        10: BabySizeInfo(week: 10, size: "Ameixa", lengthCm: 3, weightG: 4, emoji: "🍑"),
        11: BabySizeInfo(week: 11, size: "Morango", lengthCm: 4, weightG: 7, emoji: "🍓"),
        12: BabySizeInfo(week: 12, size: "Limão", lengthCm: 5, weightG: 14, emoji: "🍋"),
        13: BabySizeInfo(week: 13, size: "Mexerica", lengthCm: 7, weightG: 23, emoji: "🍊"),
        14: BabySizeInfo(week: 14, size: "Pêssego", lengthCm: 8, weightG: 43, emoji: "🍑"),
        15: BabySizeInfo(week: 15, size: "Maçã", lengthCm: 10, weightG: 70, emoji: "🍎"),
        16: BabySizeInfo(week: 16, size: "Abacate", lengthCm: 11, weightG: 100, emoji: "🥑"),
        17: BabySizeInfo(week: 17, size: "Batata", lengthCm: 13, weightG: 140, emoji: "🥔"),
        18: BabySizeInfo(week: 18, size: "Pimentão", lengthCm: 14, weightG: 190, emoji: "🫑"),
        19: BabySizeInfo(week: 19, size: "Manga", lengthCm: 15, weightG: 240, emoji: "🥭"),
        20: BabySizeInfo(week: 20, size: "Banana", lengthCm: 16, weightG: 300, emoji: "🍌"),
        21: BabySizeInfo(week: 21, size: "Cenoura", lengthCm: 26, weightG: 360, emoji: "🥕"),
        22: BabySizeInfo(week: 22, size: "Milho", lengthCm: 27, weightG: 430, emoji: "🌽"),
        23: BabySizeInfo(week: 23, size: "Pepino", lengthCm: 28, weightG: 501, emoji: "🥒"),
        24: BabySizeInfo(week: 24, size: "Milho", lengthCm: 30, weightG: 600, emoji: "🌽"),
        25: BabySizeInfo(week: 25, size: "Acorn squash", lengthCm: 34, weightG: 660, emoji: "🎃"),
        26: BabySizeInfo(week: 26, size: "Alcachofra", lengthCm: 35, weightG: 760, emoji: "🥬"),
        27: BabySizeInfo(week: 27, size: "Couve-flor", lengthCm: 36, weightG: 875, emoji: "🥦"),
        28: BabySizeInfo(week: 28, size: "Berinjela", lengthCm: 37, weightG: 1005, emoji: "🍆"),
        29: BabySizeInfo(week: 29, size: "Abóbora butternut", lengthCm: 38, weightG: 1153, emoji: "🎃"),
        30: BabySizeInfo(week: 30, size: "Repolho", lengthCm: 39, weightG: 1319, emoji: "🥬"),
        31: BabySizeInfo(week: 31, size: "Coco", lengthCm: 41, weightG: 1502, emoji: "🥥"),
        32: BabySizeInfo(week: 32, size: "Abacaxi", lengthCm: 42, weightG: 1702, emoji: "🍍"),
        33: BabySizeInfo(week: 33, size: "Aipo", lengthCm: 43, weightG: 1918, emoji: "🥬"),
        34: BabySizeInfo(week: 34, size: "Melão", lengthCm: 45, weightG: 2146, emoji: "🍈"),
        35: BabySizeInfo(week: 35, size: "Melão cantalupo", lengthCm: 46, weightG: 2383, emoji: "🍈"),
        36: BabySizeInfo(week: 36, size: "Alface romana", lengthCm: 47, weightG: 2622, emoji: "🥬"),
        37: BabySizeInfo(week: 37, size: "Swiss chard", lengthCm: 48, weightG: 2859, emoji: "🥬"),
        38: BabySizeInfo(week: 38, size: "Aipo", lengthCm: 49, weightG: 3083, emoji: "🥬"),
        39: BabySizeInfo(week: 39, size: "Melancia pequena", lengthCm: 50, weightG: 3288, emoji: "🍉"),
        40: BabySizeInfo(week: 40, size: "Melancia", lengthCm: 51, weightG: 3462, emoji: "🍉"),
        41: BabySizeInfo(week: 41, size: "Abóbora", lengthCm: 52, weightG: 3597, emoji: "🎃"),
        42: BabySizeInfo(week: 42, size: "Abóbora grande", lengthCm: 53, weightG: 3697, emoji: "🎃")
    ]
}
