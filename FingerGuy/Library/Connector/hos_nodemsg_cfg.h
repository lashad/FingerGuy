/*
 *	hos_nodemsg_cfg.h
 *
 *	Copyright (c) 2012 Picktek LLC
 *
 *	This file is part of Hyperios.
 *
 *	Hyperios is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	Hyperios is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with Hyperios.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _HOS_NODEMSG_CFG_H
#define _HOS_NODEMSG_CFG_H


/* Physical adddresss for network device. This must be unique */
#define     HOS_MY_ADDRESS                          1977

#define HOS_NODEMSG_COMMAND_GET_TEMPERATURE         100
#define HOS_NODEMSG_COMMAND_GET_LCDBACKLIGHT        101
#define HOS_NODEMSG_COMMAND_GET_DOOR                102
#define HOS_NODEMSG_COMMAND_GET_MESSAGE             103

// Low level dynamic memory allocation functin
#define HOS_NODEMSG_MEM_ALLOC(s)   malloc(s)
#define HOS_NODEMSG_MEM_FREE(p)    free(p)


#endif // _HOS_NODEMSG_CFG_H
