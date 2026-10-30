<?php

declare(strict_types=1);

namespace BjsMenus\Nutrition\Tests;

use BjsMenus\Nutrition\Menu;
use PHPUnit\Framework\TestCase;

final class MenuTest extends TestCase
{
    public function testDataset(): void { $this->assertCount(183, Menu::items()); }

    public function testFind(): void
    {
        $this->assertSame('bjs-0003', Menu::find("bj's wagyu burger")['id']);
        $this->expectException(\InvalidArgumentException::class);
        Menu::find('burger');
    }

    public function testTotal(): void
    {
        $r = Menu::total(["BJ's Wagyu Burger", '2x Avocado Egg Rolls']);
        $this->assertSame(3210, $r['totals']['cal']['sum']);
        $this->assertSame('3,210 cal', Menu::formatTotal($r['totals']['cal']));
    }

    public function testPartial(): void
    {
        $r = Menu::total(["BJ's Wagyu Burger", 'California Club Flatbread']);
        $this->assertSame(['California Club Flatbread'], $r['totals']['cal']['missing']);
        $this->assertSame('1,230 cal+', Menu::formatTotal($r['totals']['cal']));
    }

    public function testFilter(): void
    {
        $r = Menu::filter(500, null, null, ['milk']);
        $this->assertNotEmpty($r);
        foreach ($r as $i) {
            $this->assertLessThanOrEqual(500, $i['cal']);
            $this->assertNotContains('Milk', $i['allergens']);
        }
    }
}
