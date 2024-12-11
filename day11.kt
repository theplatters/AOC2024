package org.day11
import kotlin.math.abs
import kotlin.math.log10

fun ULong.countDigits() =
    when (this) {
        0uL -> 1
        else -> log10(abs(toDouble())).toInt() + 1
    }

fun blinkStone(stone: ULong): List<ULong> {
    if (stone == 0uL) {
        return listOf(1uL)
    } else if (stone.countDigits() % 2 == 0) {
        val stoneStr: String = stone.toString()
        val mid = stoneStr.length / 2
        val firstPart = stoneStr.substring(0, mid).toULong()
        val secondPart = stoneStr.substring(mid).toULong()
        return listOf(firstPart, secondPart)
    }
    return listOf(stone * 2024u)
}

fun blink(stoneMap: MutableMap<ULong, ULong>): MutableMap<ULong, ULong> {
    var newMap = mutableMapOf<ULong, ULong>()
    for (stones in stoneMap.keys) {
        for (stone in blinkStone(stones)) {
            newMap[stone] = (newMap.getOrPut(stone) { 0uL } + stoneMap[stones]!!)
        }
    }
    return newMap
}

fun main(args: Array<String>) {
    val stones: List<ULong> = listOf(9694820uL, 93uL, 54276uL, 1304uL, 314uL, 664481uL, 0uL, 4uL)

    var sum = 0
    var blink1: List<ULong> = listOf()
    for (stone in stones) {
        blink1 = listOf(stone)
        for (i in 0..24) {
            blink1 = blink1.map { blinkStone(it) }.flatten()
        }
        sum += blink1.size
    }
    println(sum)

    sum = 0

    var stoneMap = mutableMapOf<ULong, ULong>()
    for (stone in stones) {
        stoneMap.put(stone, 1uL)
    }

    for (i in 0..74) {
        stoneMap = blink(stoneMap)
    }

    println(stoneMap.values.sum())
}
