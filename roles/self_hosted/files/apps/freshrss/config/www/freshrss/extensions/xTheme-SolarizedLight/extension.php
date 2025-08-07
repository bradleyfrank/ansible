<?php
// xTheme-SolarizedLight/extension.php
final class SolarizedLightExtension extends Minz_Extension {
    public function init(): void {
        parent::init();
        // Enqueue the stylesheet on every page
        Minz_View::appendStyle($this->getFileUrl('static/solarized-light.css'));
    }
}
