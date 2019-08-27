//<?php
/**
 * Оплата по счету
 *
 * Плагин для выставления счета после оформления заказа
 *
 * @category    plugin
 * @version     0.1.1
 * @author      mnoskov
 * @internal    @events OnRegisterPayments,OnPageNotFound,OnBeforeOrderSending,OnBeforePaymentProcess
 * @internal    @properties &orgname=Название компании;text; &address=Юридический адрес;text; &inn=ИНН;text; &kpp=КПП;text; &ogrn=ОГРН;text; &contact=Руководитель;text; &account=Номер счета;text; &bank=Банк получателя;text; &bik=БИК;text; &bankaccount=Корреспонденский счет;text; &path=Путь к папке для сохранения счетов;text; &tpl_control=Имя чанка управляющей разметки;text; &tpl_bill=Имя чанка разметки счета;text; &tpl_bill_products_row=Имя чанка строки товара; &tpl_bill_subtotals_row=Имя чанка дополн. услуг;text;
 * @internal    @modx_category Commerce
 */

if (empty($modx->commerce)) {
    $modx->logEvent(0, 3, 'Ошибка! Отредактируйте порядок вызова плагинов на событии OnPageNotFound - плагин Commerce должен вызываться ДО плагина Оплата по счету.', 'Ошибка! Оплата по счету');
    return;
}

require_once MODX_BASE_PATH . 'assets/plugins/commercebillpayment/src/BillPayment.php';

$class = new BillPayment($modx, $params);

switch ($modx->Event->name) {
    case 'OnRegisterPayments':{
        $modx->commerce->registerPayment('bill', 'Выставить счет', $class);
        break;
    }

    case 'OnPageNotFound':{
        if (!empty($_GET['q']) && is_scalar($_GET['q']) && !empty($_GET['hash']) && is_scalar($_GET['hash'])) {
            $query = trim($_GET['q'], '/');

            if ($query == 'commerce/getbill') {
                echo $class->printBill($_GET['hash']);
                exit;
            }
        }

        break;
    }

    case 'OnBeforeOrderSending':{
        if (!empty($order['fields']['payment_method']) && $order['fields']['payment_method'] == 'bill') {
            $extra = $FL->getPlaceholder('extra', '');
            $url = $modx->getConfig('site_url') . 'commerce/getbill?hash=' . $params['order']['hash'];
            $FL->setPlaceholder('extra', $extra . '<p>Скачайте счет для оплаты по ссылке <a href="' . $url . '">' . $url . '</a></p>');
        }

        break;
    }

    case 'OnBeforePaymentProcess':{
        if (!empty($order['fields']['payment_method']) && $order['fields']['payment_method'] == 'bill') {
            $params['redirect_text'] = 'Ожидайте скачивания счета для оплаты...';
        }

        break;
    }
}
