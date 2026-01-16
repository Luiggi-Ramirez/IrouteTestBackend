-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 16-01-2026 a las 12:27:45
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `iroute_db_test`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_commerce` (IN `p_date` DATE, IN `p_name` VARCHAR(50), IN `p_doc` VARCHAR(250))   BEGIN
    INSERT INTO commerce (pc_processdate, pc_nomcomred, pc_numdoc)
    VALUES (p_date, p_name, p_doc);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_process_quarantine` (IN `p_date` DATE)   BEGIN
    -- 1. Insertar en quarantine los registros con nombre vacío
    INSERT INTO commerce_quarentine (pc_processdate, pc_nomcomred, pc_numdoc, motivo)
    SELECT pc_processdate, pc_nomcomred, pc_numdoc, 'El nombre del comercio (nomcomred) se encuentra vacio'
    FROM commerce 
    WHERE pc_processdate = p_date AND (pc_nomcomred IS NULL OR pc_nomcomred = '');

    -- 2. Insertar en quarantine los registros con pc_numdoc inválido (caracteres no numéricos)
    INSERT INTO commerce_quarentine (pc_processdate, pc_nomcomred, pc_numdoc, motivo)
    SELECT pc_processdate, pc_nomcomred, pc_numdoc, 'El número (numdoc) contiene letras o caracteres especiales'
    FROM commerce 
    WHERE pc_processdate = p_date 
      AND (pc_numdoc REGEXP '[^0-9]') 
      AND (pc_nomcomred IS NOT NULL AND pc_nomcomred <> ''); -- Evitar duplicar si ya falló el anterior

    -- 3. Borrar de la tabla original los registros movidos
    DELETE FROM commerce 
    WHERE pc_processdate = p_date 
      AND (pc_nomcomred IS NULL OR pc_nomcomred = '' OR pc_numdoc REGEXP '[^0-9]');

    -- 4. Retornar conteo
    SELECT COUNT(*) FROM commerce_quarentine WHERE pc_processdate = p_date;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `commerce`
--

CREATE TABLE `commerce` (
  `id` bigint(20) NOT NULL COMMENT 'Id',
  `pc_processdate` date NOT NULL COMMENT 'fecha de proceso',
  `pc_nomcomred` varchar(50) DEFAULT NULL,
  `pc_numdoc` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `commerce`
--

INSERT INTO `commerce` (`id`, `pc_processdate`, `pc_nomcomred`, `pc_numdoc`) VALUES
(3, '0000-00-00', 'comercio exemplo 2', 'a'),
(4, '2025-03-20', 'comercio nombre exemplo', '1'),
(7, '2025-03-20', 'comercio nombre exemplo', '1'),
(10, '2025-03-21', 'comercio nombre exemplo del 21', '1'),
(13, '2025-03-21', 'comercio nombre exemplo del 21', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `commerce_quarentine`
--

CREATE TABLE `commerce_quarentine` (
  `id` bigint(20) NOT NULL,
  `pc_processdate` date NOT NULL,
  `pc_nomcomred` varchar(50) DEFAULT NULL,
  `pc_numdoc` varchar(50) DEFAULT NULL,
  `motivo` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `commerce_quarentine`
--

INSERT INTO `commerce_quarentine` (`id`, `pc_processdate`, `pc_nomcomred`, `pc_numdoc`, `motivo`) VALUES
(1, '2025-03-20', '', '1', 'El nombre del comercio (nomcomred) se encuentra vacio'),
(2, '2025-03-20', '', '1', 'El nombre del comercio (nomcomred) se encuentra vacio'),
(4, '2025-03-20', 'comercio exemplo 2', '0', 'El número (numdoc) contiene letras o caracteres especiales'),
(5, '2025-03-20', 'comercio exemplo 2', '0', 'El número (numdoc) contiene letras o caracteres especiales'),
(7, '2025-03-21', '', '1', 'El nombre del comercio (nomcomred) se encuentra vacio'),
(8, '2025-03-21', 'comercio exemplo 21', '0', 'El número (numdoc) contiene letras o caracteres especiales'),
(9, '2025-03-21', '', '1ab', 'El nombre del comercio (nomcomred) se encuentra vacio'),
(10, '2025-03-21', 'comercio exemplo 21', 'a', 'El número (numdoc) contiene letras o caracteres especiales');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `commerce`
--
ALTER TABLE `commerce`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indices de la tabla `commerce_quarentine`
--
ALTER TABLE `commerce_quarentine`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `commerce`
--
ALTER TABLE `commerce`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Id', AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `commerce_quarentine`
--
ALTER TABLE `commerce_quarentine`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
