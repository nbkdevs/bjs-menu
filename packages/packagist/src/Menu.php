<?php

declare(strict_types=1);

namespace BjsMenus\Nutrition;

/**
 * Offline BJ's Restaurant meal builder: nutrition totals, missing-value flags,
 * search and calorie/allergen filters. Data collected by https://bjsmenus.com/.
 */
final class Menu
{
    public const NUTRIENTS = ['cal', 'protein', 'carbs', 'fat', 'sodium'];
    public const UNITS = ['cal' => 'cal', 'protein' => 'g', 'carbs' => 'g', 'fat' => 'g', 'sodium' => 'mg'];

    /** @var list<array<string,mixed>>|null */
    private static ?array $items = null;

    /** @return list<array<string,mixed>> */
    public static function items(): array
    {
        if (self::$items === null) {
            $data = json_decode((string) file_get_contents(__DIR__ . '/menu.json'), true, 512, JSON_THROW_ON_ERROR);
            self::$items = $data['items'];
        }
        return self::$items;
    }

    public static function norm(string $s): string
    {
        $s = str_replace(["'", "\u{2018}", "\u{2019}"], '', strtolower($s));
        return trim((string) preg_replace('/[^a-z0-9]+/', ' ', $s));
    }

    /** @return list<string> */
    public static function categories(): array
    {
        return array_values(array_unique(array_map(fn ($i) => $i['category'], self::items())));
    }

    /** @return list<array<string,mixed>> */
    public static function search(string $query): array
    {
        $q = self::norm($query);
        if ($q === '') {
            return [];
        }
        $words = explode(' ', $q);
        return array_values(array_filter(self::items(), function ($i) use ($words) {
            $n = self::norm($i['name']);
            foreach ($words as $w) {
                if (!str_contains($n, $w)) {
                    return false;
                }
            }
            return true;
        }));
    }

    /** Find by id, exact name, or a query matching exactly one item. @return array<string,mixed> */
    public static function find(string $ref): array
    {
        $q = self::norm($ref);
        foreach (self::items() as $i) {
            if ($i['id'] === $ref || self::norm($i['name']) === $q) {
                return $i;
            }
        }
        $hits = self::search($ref);
        if (count($hits) === 1) {
            return $hits[0];
        }
        if ($hits === []) {
            throw new \InvalidArgumentException(sprintf('No menu item matches "%s"', $ref));
        }
        $names = implode('; ', array_map(fn ($h) => $h['name'], array_slice($hits, 0, 5)));
        throw new \InvalidArgumentException(sprintf('"%s" matches %d items: %s', $ref, count($hits), $names));
    }

    /** "2x Avocado Egg Rolls" => ['Avocado Egg Rolls', 2]. @return array{0:string,1:int} */
    public static function parseLine(string $text): array
    {
        if (preg_match('/^\s*(\d+)\s*[xX×]\s+(.+)$/u', $text, $m)) {
            return [trim($m[2]), (int) $m[1]];
        }
        return [trim($text), 1];
    }

    /**
     * Total a meal. Lines are "2x Name" strings or [ref, qty] pairs. Items with no published
     * value for a nutrient, or listed per slice, are not added and are named in "missing".
     *
     * @param list<string|array{0:string,1:int}> $lines
     * @return array<string,mixed>
     */
    public static function total(array $lines): array
    {
        $resolved = [];
        foreach ($lines as $l) {
            [$ref, $qty] = is_string($l) ? self::parseLine($l) : $l;
            $item = self::find($ref);
            if (!is_int($qty) || $qty < 1 || $qty > 99) {
                throw new \InvalidArgumentException(sprintf('Quantity for %s must be 1-99', $item['name']));
            }
            $resolved[] = [$item, $qty];
        }
        $totals = [];
        foreach (self::NUTRIENTS as $k) {
            $sum = 0;
            $missing = [];
            foreach ($resolved as [$item, $qty]) {
                if ($item[$k] === null || $item['perSlice']) {
                    $missing[] = $item['name'];
                } else {
                    $sum += $item[$k] * $qty;
                }
            }
            $totals[$k] = ['sum' => $sum, 'unit' => self::UNITS[$k], 'missing' => $missing, 'partial' => $missing !== [],
                'listed' => $resolved !== [] && count($missing) < count($resolved)];
        }
        $allergens = [];
        $unknown = [];
        foreach ($resolved as [$item]) {
            if ($item['allergens'] === null) {
                $unknown[] = $item['name'];
            } else {
                array_push($allergens, ...$item['allergens']);
            }
        }
        $allergens = array_values(array_unique($allergens));
        sort($allergens);
        return [
            'lines' => array_map(fn ($r) => ['name' => $r[0]['name'], 'qty' => $r[1]], $resolved),
            'totals' => $totals,
            'allergens' => $allergens,
            'allergenUnknown' => $unknown,
        ];
    }

    /**
     * Items matching every limit. Unknown allergen info never passes a "without" filter.
     *
     * @param list<string> $without
     * @return list<array<string,mixed>>
     */
    public static function filter(?int $maxCal = null, ?int $minProtein = null, ?int $maxSodium = null, array $without = [], ?string $role = null): array
    {
        $wo = array_values(array_filter(array_map([self::class, 'norm'], $without)));
        return array_values(array_filter(self::items(), function ($i) use ($maxCal, $minProtein, $maxSodium, $wo, $role) {
            if ($role !== null && $i['role'] !== $role) return false;
            if ($maxCal !== null && ($i['cal'] === null || $i['perSlice'] || $i['cal'] > $maxCal)) return false;
            if ($minProtein !== null && ($i['protein'] === null || $i['protein'] < $minProtein)) return false;
            if ($maxSodium !== null && ($i['sodium'] === null || $i['sodium'] > $maxSodium)) return false;
            if ($wo !== []) {
                if ($i['allergens'] === null) return false;
                foreach ($i['allergens'] as $a) {
                    if (in_array(self::norm($a), $wo, true)) return false;
                }
            }
            return true;
        }));
    }

    /** @param array<string,mixed> $t */
    public static function formatTotal(array $t): string
    {
        if (!$t['listed']) {
            return 'Not listed';
        }
        return number_format($t['sum']) . ' ' . $t['unit'] . ($t['partial'] ? '+' : '');
    }
}
