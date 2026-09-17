<?php
// ---------------------------------------------------------------------------
//  Ablage des Rentenplaners auf dem NAS.
//
//  GET  speichern.php?pruefen=1   meldet, ob das Skript laeuft und ob der
//                                 Ordner "daten" beschreibbar ist.
//  GET  speichern.php             liefert den zuletzt gespeicherten Stand.
//  POST speichern.php             nimmt einen Stand entgegen und legt ihn ab.
//
//  Der Stand liegt in daten/aktuell.json. Vor jedem Ueberschreiben wird eine
//  Sicherungskopie angelegt; die letzten zehn bleiben erhalten.
//
//  Erreichbar ist das Skript nur ueber das Tailnet. Eine Anmeldung findet
//  nicht statt - wer die Seite oeffnen kann, kann auch speichern.
// ---------------------------------------------------------------------------

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

$ordner = __DIR__ . '/daten';
$datei  = $ordner . '/aktuell.json';

// ------------------------------------------------------------------- Lesen
if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    if (isset($_GET['pruefen'])) {
        $schreibbar = is_dir($ordner) ? is_writable($ordner) : is_writable(__DIR__);
        echo json_encode(array(
            'ok'         => true,
            'schreibbar' => $schreibbar,
            'vorhanden'  => is_file($datei),
            'geaendert'  => is_file($datei) ? date('c', filemtime($datei)) : null,
            'bytes'      => is_file($datei) ? filesize($datei) : 0,
        ));
        exit;
    }

    if (!is_file($datei)) { echo 'null'; exit; }
    readfile($datei);
    exit;
}

// ---------------------------------------------------------------- Schreiben
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $roh = file_get_contents('php://input');
    $obj = json_decode($roh, true);

    if (!is_array($obj) || !isset($obj['cfg'])) {
        http_response_code(400);
        echo json_encode(array('ok' => false, 'fehler' => 'Der gesendete Inhalt ist kein gueltiger Stand.'));
        exit;
    }

    if (!is_dir($ordner) && !@mkdir($ordner, 0775, true)) {
        http_response_code(500);
        echo json_encode(array('ok' => false, 'fehler' => 'Der Ordner "daten" konnte nicht angelegt werden.'));
        exit;
    }

    // Sicherungskopie des bisherigen Standes, die letzten zehn bleiben stehen.
    if (is_file($datei)) {
        @copy($datei, $ordner . '/sicherung_' . date('Ymd_His') . '.json');
        $alte = glob($ordner . '/sicherung_*.json');
        if ($alte && count($alte) > 10) {
            sort($alte);
            foreach (array_slice($alte, 0, count($alte) - 10) as $weg) @unlink($weg);
        }
    }

    // Erst in eine Nebendatei schreiben, dann umbenennen. So bleibt bei einem
    // Abbruch mitten im Schreiben der alte Stand unversehrt.
    $zwischen = $datei . '.tmp';
    if (file_put_contents($zwischen, $roh) === false || !@rename($zwischen, $datei)) {
        @unlink($zwischen);
        http_response_code(500);
        echo json_encode(array('ok' => false, 'fehler' => 'Die Datei konnte nicht geschrieben werden (Schreibrecht pruefen).'));
        exit;
    }

    echo json_encode(array('ok' => true, 'gespeichert' => date('c'), 'bytes' => strlen($roh)));
    exit;
}

http_response_code(405);
echo json_encode(array('ok' => false, 'fehler' => 'Methode nicht erlaubt.'));
